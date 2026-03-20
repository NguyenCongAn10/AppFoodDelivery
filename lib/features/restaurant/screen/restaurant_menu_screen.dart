import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/restaurant_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../widget/restaurant_add_item_bottom_sheet.dart';

class RestaurantMenuScreen extends StatefulWidget {
  const RestaurantMenuScreen({super.key});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  final BackendService _backendService = BackendService();
  RestaurantModel? _restaurant;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final restaurant = await _backendService.getMyRestaurant();
      setState(() {
        _restaurant = restaurant;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching menu: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAvailability(FoodModel food, bool isAvailable) async {
    try {
      await _backendService.updateFood(food.id, {'is_available': isAvailable});
      _fetchData(); // Refresh list
    } catch (e) {
      debugPrint('Error toggling availability: $e');
    }
  }

  Future<void> _deleteItem(FoodModel food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete ${food.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _backendService.deleteFood(food.id);
        _fetchData();
      } catch (e) {
        debugPrint('Error deleting food: $e');
      }
    }
  }

  Future<void> _editItem(FoodModel food) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RestaurantAddItemBottomSheet(food: food),
    );
    if (result == true) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<FoodModel>>{};
    if (_restaurant != null && _restaurant!.foods != null) {
      for (final food in _restaurant!.foods!) {
        final categoryName = food.categoryName?.isNotEmpty == true
            ? food.categoryName!
            : 'Others';
        grouped.putIfAbsent(categoryName, () => []).add(food);
      }
    }

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text('Menu', style: AppTextStyle.bodyBold(context, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const RestaurantAddItemBottomSheet(),
          );
          if (result == true) {
            _fetchData();
          }
        },
        backgroundColor: AppColor.primary(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Item', style: AppTextStyle.bodyBold(context, color: Colors.white, fontSize: 14)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: grouped.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          entry.key,
                          style: AppTextStyle.bodyBold(context, fontSize: 15, color: AppColor.textSecondary(context)),
                        ),
                      ),
                      ...entry.value.map(
                        (food) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Slidable(
                            key: ValueKey(food.id),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                CustomSlidableAction(
                                  onPressed: (_) => _editItem(food),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 22),
                                  ),
                                ),
                                CustomSlidableAction(
                                  onPressed: (_) => _deleteItem(food),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.delete,
                                        color: Colors.white, size: 22),
                                  ),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColor.container(context),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(food.name,
                                                style: AppTextStyle.bodyBold(
                                                    context,
                                                    fontSize: 16)),
                                            if (food.description != null &&
                                                food.description!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                food.description!,
                                                style: AppTextStyle.body(
                                                    context,
                                                    fontSize: 13,
                                                    color:
                                                        AppColor.textSecondary(
                                                            context)),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Text(
                                              '\$ ${food.price.toStringAsFixed(0)}',
                                              style: AppTextStyle.bodyBold(
                                                  context,
                                                  fontSize: 15,
                                                  color: AppColor.textAccent(
                                                      context)),
                                            ),
                                            if (food
                                                .optionGroups.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Wrap(
                                                spacing: 6,
                                                runSpacing: 6,
                                                children: food.optionGroups
                                                    .map((group) {
                                                  final optionsText = group
                                                      .options
                                                      .map((o) => o.name)
                                                      .join(', ');
                                                  return Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColor
                                                          .secondaryBackground(
                                                              context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Text(
                                                      '${group.name}: $optionsText',
                                                      style:
                                                          AppTextStyle.bodyBold(
                                                              context,
                                                              fontSize: 11,
                                                              color: AppColor
                                                                  .textTitle(
                                                                      context)),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: AppColor.primary(context)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: food.imageUrl != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Image.network(
                                                    food.imageUrl!,
                                                    fit: BoxFit.cover),
                                              )
                                            : Icon(Icons.fastfood_rounded,
                                                color:
                                                    AppColor.primary(context),
                                                size: 32),
                                      ),
                                    ],
                                  ),
                                ),
                                // Round toggle button on top right of the card
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _toggleAvailability(
                                        food, !food.isAvailable),
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: food.isAvailable
                                            ? Colors.blue
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2))
                                        ],
                                      ),
                                      child: Icon(
                                        food.isAvailable
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
