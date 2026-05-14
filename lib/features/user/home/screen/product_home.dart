import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';

import 'package:delivery_apps/features/user/favorites/provider/favorite_provider.dart';
import 'package:delivery_apps/features/user/home/screen/product_detail_page.dart';
import 'package:delivery_apps/features/user/cart/provider/cart_provider.dart';
import 'package:delivery_apps/features/user/home/widget/categories_slider.dart';
import 'package:delivery_apps/features/user/home/widget/food_options_bottom_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  final BackendService _backendService = BackendService();
  List<FoodModel> foods = [];
  String selectedCategory = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts({String? categoryId}) async {
    if (!mounted) return;
    setState(() => isLoading = true);
    
    try {
      final List<FoodModel> loadedFoods =
          await _backendService.getFoods(categoryId: categoryId);
      
      if (!mounted) return;
      setState(() {
        foods = loadedFoods;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint("Lỗi khi tải sản phẩm: $e");
      if (!mounted) return;
      setState(() {
        foods = [];
        isLoading = false;
      });
    }
  }



  void _onCategorySelected(String categoryId) {
    setState(() => selectedCategory = categoryId);
    _loadProducts(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Column(
      children: [
        CategoriesSlider(onCategorySelected: _onCategorySelected),
        const SizedBox(height: 20),
        Row(
          children: [
            Text("Top Picks",
                style: AppTextStyle.bodyBold(context,
                    color: AppColor.textTitle(context))),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
        SizedBox(
          width: media.width,
          child: isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()))
              : foods.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "No products available",
                          style: AppTextStyle.body(context, color: Colors.red),
                        ),
                      ),
                    )
                  : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemCount: foods.length,
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  food: food,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColor.container(context),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                        child: (food.imageUrl ?? "").isEmpty
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : CachedNetworkImage(
                                                imageUrl: food.imageUrl ?? "",
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                      ),
                                      Consumer<FavoriteProvider>(
                                        builder: (context, favoriteProvider, child) {
                                          final isFav = favoriteProvider.isFavorite(food.id);
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                  color:
                                                      AppColor.container(context),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4,
                                                    )
                                                  ]),
                                              child: IconButton(
                                                onPressed: () =>
                                                    favoriteProvider.toggleFavorite(food),
                                                icon: Icon(
                                                  isFav ? Icons.favorite : Icons.favorite_border,
                                                  color: isFav ? Colors.red : AppColor.textSecondary(context),
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        style: AppTextStyle.bodyBold(context,
                                            fontSize: 13,
                                            color: AppColor.textTitle(context)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      if (food.restaurantName != null)
                                        Text(
                                          food.restaurantName!,
                                          style: AppTextStyle.body(context,
                                              fontSize: 11,
                                              color: AppColor.textSecondary(context)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "\$${food.price}",
                                            style: AppTextStyle.bodyBold(
                                                context,
                                                fontSize: 14,
                                                color: AppColor.textAccent(
                                                    context)),
                                          ),
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: AppColor.primary(context),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: IconButton(
                                              onPressed: () async {
                                                if (food.optionGroups.isNotEmpty) {
                                                  showModalBottomSheet(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    backgroundColor: Colors.transparent,
                                                    builder: (context) => FoodOptionsBottomSheet(
                                                      food: food,
                                                      restaurantId: food.restaurantId,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                
                                                try {
                                                  final cart = context
                                                      .read<CartProvider>();
                                                  await cart.addFood(
                                                      food, food.restaurantId);
                                                  
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Added to cart")),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content:
                                                              Text("Error: $e"),
                                                          backgroundColor:
                                                              Colors.red),
                                                    );
                                                  }
                                                }
                                              },
                                              icon: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 20),
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                ),
        ),
      ],
    );
  }
}
