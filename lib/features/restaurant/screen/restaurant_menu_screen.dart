import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/restaurant_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  void _editItem(FoodModel food) {
    // TODO: Implement Edit Dialog or Navigate to Edit Screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${food.name} - Coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<FoodModel>>{};
    if (_restaurant != null && _restaurant!.foods != null) {
      for (final food in _restaurant!.foods!) {
        // Use category name if available, otherwise default to 'Other'
        final categoryName = food.optionGroups.isNotEmpty ? 'Featured' : 'Menu Items'; 
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
        onPressed: () {
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
                                SlidableAction(
                                  onPressed: (_) => _editItem(food),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Edit',
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                                ),
                                SlidableAction(
                                  onPressed: (_) => _deleteItem(food),
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColor.container(context),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary(context).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: food.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(food.imageUrl!, fit: BoxFit.cover),
                                          )
                                        : Icon(Icons.fastfood_rounded, color: AppColor.primary(context), size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(food.name, style: AppTextStyle.bodyBold(context, fontSize: 14)),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Rs. ${food.price.toStringAsFixed(0)}',
                                          style: AppTextStyle.body(context, fontSize: 13, color: AppColor.primary(context)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Switch(
                                        value: food.isAvailable,
                                        activeColor: AppColor.primary(context),
                                        onChanged: (val) => _toggleAvailability(food, val),
                                      ),
                                      Text(
                                        food.isAvailable ? 'Available' : 'Off',
                                        style: AppTextStyle.body(
                                          context,
                                          fontSize: 11,
                                          color: food.isAvailable ? Colors.green : AppColor.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
