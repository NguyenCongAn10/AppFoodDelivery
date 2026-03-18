import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/restaurant_search_result.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/user/home/providers/user_address_provider.dart';
import 'package:delivery_apps/features/user/home/screen/restaurant_detail_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BackendService _backendService = BackendService();

  List<RestaurantSearchResult> _results = [];
  List<String> _searchHistory = [];
  List<FoodModel> _suggestions = [];
  bool _isLoading = false;
  bool _isHistoryExpanded = false;
  String _lastQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _loadSuggestionsIfNeeded();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('search_history') ?? [];
    setState(() {
      _searchHistory = history;
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('search_history', _searchHistory);
  }

  void _addToHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _searchHistory
          .removeWhere((q) => q.toLowerCase() == trimmed.toLowerCase());
      _searchHistory.insert(0, trimmed);
      if (_searchHistory.length > 10) {
        _searchHistory = _searchHistory.sublist(0, 10);
      }
    });
    _saveSearchHistory();
  }

  Future<void> _loadSuggestionsIfNeeded() async {
    if (_suggestions.isNotEmpty) return;
    try {
      final List<FoodModel> foods =
          await _backendService.getSearchSuggestions();
      setState(() {
        _suggestions = foods.take(9).toList();
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading suggestions: $e');
      }
    }
  }

  Future<void> _searchRestaurants(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      _loadSuggestionsIfNeeded();
      return;
    }

    setState(() {
      _isLoading = true;
      _lastQuery = trimmed;
    });

    try {
      final address = context.read<UserAddressProvider>().selectedAddress;

      final results = await _backendService.searchRestaurantsByFood(
        query: trimmed,
        latitude: address?.latitude,
        longitude: address?.longitude,
      );

      setState(() {
        if (_lastQuery == trimmed) {
          _results = results;
        }
      });

      if (results.isNotEmpty) {
        _addToHistory(trimmed);
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error while searching: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      if (query.trim().isEmpty) {
        setState(() {
          _lastQuery = '';
          _results = [];
        });
        _loadSuggestionsIfNeeded();
      } else {
        _searchRestaurants(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SafeArea(
              child: Row(
                children: [
                  RoundIconCircle(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined),
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RoundTextField(
                      textEditingController: _searchController,
                      hint: "Search your food",
                      preicon: Icon(
                        Icons.search,
                        color: AppColor.textTitle(context),
                      ),
                      sufIconWidget: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _searchController.clear();
                                  _results = [];
                                  _loadSuggestionsIfNeeded();
                                });
                              },
                              child: Icon(
                                Icons.clear,
                                color: AppColor.textTitle(context),
                              ),
                            )
                          : null,
                      obscureText: false,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 0),
                      sufIcon: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColor.primary(context),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 24, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchController.text.trim().isEmpty
                      ? _buildHistoryAndSuggestions(context)
                      : _results.isEmpty
                          ? Center(
                              child: Text(
                                "No matching restaurants found",
                                style: AppTextStyle.body(
                                  context,
                                  color: AppColor.textBody(context),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(10),
                              itemCount: _results.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RestaurantDetailScreen(
                                                restaurantId: _results[index].id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: restaurantResultCard(
                                    context,
                                    _results[index],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryAndSuggestions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_searchHistory.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent searches",
                  style: AppTextStyle.bodyBold(
                    context,
                    color: AppColor.textTitle(context),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchHistory.clear();
                      _isHistoryExpanded = false;
                    });
                    _saveSearchHistory();
                  },
                  child: Text(
                    "Clear",
                    style: AppTextStyle.body(
                      context,
                      color: AppColor.primary(context),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: Column(
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._searchHistory
                          .take(_isHistoryExpanded ? _searchHistory.length : 2)
                          .map(
                            (q) => ActionChip(
                              label: Text(q),
                              onPressed: () {
                                _searchController.text = q;
                                _searchRestaurants(q);
                              },
                            ),
                          ),
                    ],
                  ),
                  if (_searchHistory.length > 2)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _isHistoryExpanded = !_isHistoryExpanded),
                        child: Icon(
                          _isHistoryExpanded
                              ? Icons.expand_less_outlined
                              : Icons.expand_more_outlined,
                          color: AppColor.primary(context),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          Text(
            "Suggestions",
            style: AppTextStyle.bodyBold(
              context,
              color: AppColor.textTitle(context),
            ),
          ),
          const SizedBox(height: 12),
          if (_suggestions.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final food = _suggestions[index];
                return GestureDetector(
                  onTap: () {
                    _searchController.text = food.name;
                    _searchRestaurants(food.name);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: food.imageUrl != null &&
                                food.imageUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: food.imageUrl!,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.grey.shade200,
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 72,
                                  height: 72,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.fastfood,
                                    size: 24,
                                  ),
                                ),
                              )
                            : Container(
                                width: 72,
                                height: 72,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 24,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        food.name,
                        style: AppTextStyle.body(
                          context,
                          color: AppColor.textBody(context),
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

Widget restaurantResultCard(
  BuildContext context,
  RestaurantSearchResult item,
) {
  final distanceText = item.distanceKm != null
      ? '${item.distanceKm!.toStringAsFixed(1)} km'
      : null;
  final coverFood =
      item.matchedFoods.isNotEmpty ? item.matchedFoods.first : null;
  final restaurantImage = item.imageUrl;

  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailScreen(
            restaurantId: item.id,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRestaurantImage(restaurantImage, coverFood?.imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyle.bodyBold(
                        context,
                        color: AppColor.textTitle(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: AppTextStyle.body(
                            context,
                            color: AppColor.textBody(context),
                          ),
                        ),
                        if (item.ratingCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${item.ratingCount})',
                            style: AppTextStyle.body(
                              context,
                              color: AppColor.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (distanceText != null) ...[
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.location_on,
                            size: 16,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            distanceText,
                            style: AppTextStyle.body(
                              context,
                              color: AppColor.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.address,
                      style: AppTextStyle.body(
                        context,
                        color: AppColor.textSecondary(context),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (item.matchedFoods.isNotEmpty)
            _buildMatchingDishesSection(context, item.matchedFoods),
        ],
      ),
    ),
  );
}

Widget _buildRestaurantImage(String? restaurantImage, String? coverFoodImage) {
  final String? imageToShow =
      (restaurantImage != null && restaurantImage.isNotEmpty)
          ? restaurantImage
          : (coverFoodImage != null && coverFoodImage.isNotEmpty)
              ? coverFoodImage
              : null;

  if (imageToShow == null) {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.storefront,
        size: 32,
      ),
    );
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: CachedNetworkImage(
      imageUrl: imageToShow,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 72,
        height: 72,
        color: Colors.grey.shade200,
        child: const Icon(
          Icons.storefront,
          size: 32,
        ),
      ),
    ),
  );
}

Widget _buildMatchingDishesSection(
  BuildContext context,
  List<MatchedFood> matchedFoods,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Matching dishes",
        style: AppTextStyle.bodyBold(
          context,
          fontSize: 13,
          color: AppColor.textTitle(context),
        ),
      ),
      const SizedBox(height: 6),
      Column(
        children: matchedFoods
            .map(
              (food) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: food.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 20,
                                ),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.fastfood,
                                size: 20,
                              ),
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.name,
                            style: AppTextStyle.body(
                              context,
                              color: AppColor.textBody(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\$${food.price.toStringAsFixed(2)}',
                            style: AppTextStyle.bodyBold(
                              context,
                              color: AppColor.textAccent(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ],
  );
}
