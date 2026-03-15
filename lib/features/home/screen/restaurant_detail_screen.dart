import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/models/restaurant_detail_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/cart/provider/cart_provider.dart';
import 'package:delivery_apps/features/home/screen/main_screen.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:delivery_apps/features/home/widget/food_options_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final BackendService _backendService = BackendService();
  RestaurantDetailModel? _restaurant;
  bool _isLoading = true;
  String? _error;

  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantDetail();
  }

  Future<void> _fetchRestaurantDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _backendService.getRestaurantDetail(widget.restaurantId);

      setState(() {
        _restaurant = data;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint("Error fetching restaurant detail: $e");
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Cart logic moved to CartProvider

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.inputFill(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _restaurant == null) {
      return Scaffold(
        backgroundColor: AppColor.inputFill(context),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading restaurant',
                  style: AppTextStyle.title(context)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _fetchRestaurantDetail,
                child: const Text('Try Again'),
              )
            ],
          ),
        ),
      );
    }

    final restaurant = _restaurant!;
    final coverImage = restaurant.imageUrl ??
        (restaurant.menu.expand((c) => c.foods).firstOrNull?.imageUrl ?? '');

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColor.inputFill(context),
            leadingWidth: 70,
            leading: Center(
              child: RoundIconCircle(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              RoundIconCircle(
                icon: const Icon(Icons.shopping_cart_rounded, size: 22),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 1)),
                  );
                },
              ),
              const SizedBox(width: 15),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: coverImage.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverImage,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.store, size: 80, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.store, size: 80, color: Colors.white),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(8),
              color: AppColor.inputFill(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: AppTextStyle.title(context, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade600, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyle.bodyBold(context, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (restaurant.menu.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                minHeight: 50.0,
                maxHeight: 50.0,
                child: Container(
                  color: AppColor.inputFill(context),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurant.menu.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      final category = restaurant.menu[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(right: 24),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                category.categoryName,
                                style: isSelected
                                    ? AppTextStyle.bodyBold(context, fontSize: 16).copyWith(color: AppColor.primary(context))
                                    : AppTextStyle.body(context,
                                        fontSize: 16,
                                        color: AppColor.textSecondary(context)),
                              ),
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 2,
                                  width: 40,
                                  color: AppColor.primary(context),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

          if (restaurant.menu.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final food = restaurant.menu[_selectedCategoryIndex].foods[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(food: food),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColor.container(context), // Background color
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: food.imageUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) => Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.fastfood),
                                      ),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.fastfood),
                                    ),
                            ),
                            const SizedBox(width: 16),

                            // Food Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.name,
                                    style: AppTextStyle.bodyBold(context, fontSize: 16),
                                  ),
                                  const SizedBox(height: 6),
                                  if (food.description != null && food.description!.isNotEmpty)
                                    Text(
                                      food.description!,
                                      style: AppTextStyle.body(context, 
                                          color: AppColor.textSecondary(context),
                                          fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 12),
                                  Consumer<CartProvider>(
                                    builder: (context, cart, child) {
                                      final quantity = cart.getQuantity(food.id);
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '\$ ${food.price.toStringAsFixed(0)}',
                                              style: AppTextStyle.accent(context,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          if (quantity > 0) ...[
                                            GestureDetector(
                                              onTap: () => cart.removeFood(food.id),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColor.primary(context),
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 20,
                                                  color: AppColor.primary(context),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              quantity.toString(),
                                              style: AppTextStyle.bodyBold(context, fontSize: 16),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          GestureDetector(
                                            onTap: () {
                                              if (food.optionGroups.isNotEmpty) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (context) => FoodOptionsBottomSheet(
                                                    food: food,
                                                    restaurantId: restaurant.id,
                                                  ),
                                                );
                                                return;
                                              }
                                              cart.addFood(food, restaurant.id);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColor.primary(context),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 20,
                                                color: AppColor.primary(context),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: restaurant.menu[_selectedCategoryIndex].foods.length,
                ),
              ),
            ),

          // If no menu exists
          if (restaurant.menu.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No menu available',
                  style: AppTextStyle.body(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}