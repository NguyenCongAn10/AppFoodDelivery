import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/models/restaurant_detail_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/user/cart/provider/cart_provider.dart';
import 'package:delivery_apps/features/user/home/screen/main_screen.dart';
import 'package:delivery_apps/features/user/home/screen/product_detail_page.dart';
import 'package:delivery_apps/features/user/home/widget/food_options_bottom_sheet.dart';
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
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) return const SizedBox.shrink();
          final total = cart.items.fold<double>(
              0,
              (sum, i) =>
                  sum +
                  (double.tryParse(i.price) ?? 0) *
                      (double.tryParse(i.quantity) ?? 1));
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            decoration: BoxDecoration(
              color: AppColor.container(context),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4)),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 1))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${cart.items.length} items',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ),
                  const Text('View Cart',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text('\$${total.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                ],
              ),
            ),
          );
        },
      ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              color: AppColor.inputFill(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: AppTextStyle.title(context, fontSize: 22)),
                  const SizedBox(height: 8),
                  // Row(
                  //   children: [
                  //     // Icon(Icons.star_rounded,
                  //     //     color: Colors.amber.shade600, size: 18),
                  //     // const SizedBox(width: 4),
                  //     // Text(restaurant.rating.toStringAsFixed(1),
                  //     //     style: AppTextStyle.bodyBold(context, fontSize: 14)),
                  //     // const SizedBox(width: 12),
                  //     // Icon(Icons.place_outlined,
                  //     //     size: 15, color: AppColor.textSecondary(context)),
                  //     // const SizedBox(width: 4),
                  //     Expanded(
                  //       child: Text(restaurant.address,
                  //           style: AppTextStyle.body(context,
                  //               fontSize: 13,
                  //               color: AppColor.textSecondary(context)),
                  //           maxLines: 1,
                  //           overflow: TextOverflow.ellipsis),
                  //     ),
                  //   ],
                  // ),
                  Row(
                    children: [
                      Icon(Icons.place_outlined, size: 15),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(restaurant.address,
                            style: AppTextStyle.body(context,
                                fontSize: 13,
                                color: AppColor.textSecondary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
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
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColor.container(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Food Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: food.imageUrl != null &&
                                      food.imageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: food.imageUrl!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          _foodPlaceholder(),
                                    )
                                  : _foodPlaceholder(),
                            ),
                            const SizedBox(width: 14),
                            // Food Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(food.name,
                                      style: AppTextStyle.bodyBold(context,
                                          fontSize: 15)),
                                  if (food.description != null &&
                                      food.description!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(food.description!,
                                        style: AppTextStyle.body(context,
                                            color:
                                                AppColor.textSecondary(context),
                                            fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                  const SizedBox(height: 10),
                                  Consumer<CartProvider>(
                                    builder: (context, cart, _) {
                                      final quantity = cart.getQuantity(food.id);
                                      return Row(
                                        children: [
                                          Text(
                                            '\$${food.price.toStringAsFixed(0)}',
                                            style: AppTextStyle.accent(context,
                                                fontSize: 15),
                                          ),
                                          const Spacer(),
                                          if (quantity > 0) ...[
                                            _cartButton(
                                              icon: Icons.remove,
                                              color: AppColor.primary(context),
                                              onTap: () =>
                                                  cart.removeFood(food.id),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(quantity.toString(),
                                                style: AppTextStyle.bodyBold(
                                                    context,
                                                    fontSize: 15)),
                                            const SizedBox(width: 10),
                                          ],
                                          _cartButton(
                                            icon: Icons.add,
                                            color: AppColor.primary(context),
                                            filled: true,
                                            onTap: () {
                                              if (food.optionGroups.isNotEmpty) {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (_) =>
                                                      FoodOptionsBottomSheet(
                                                    food: food,
                                                    restaurantId: restaurant.id,
                                                  ),
                                                );
                                                return;
                                              }
                                              cart.addFood(food, restaurant.id);
                                            },
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

Widget _foodPlaceholder() => Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade200,
      child:
          Icon(Icons.fastfood_rounded, color: Colors.grey.shade400, size: 32),
    );

Widget _cartButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  bool filled = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 18, color: filled ? Colors.white : color),
    ),
  );
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