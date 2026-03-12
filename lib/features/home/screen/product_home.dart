import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/backend_service.dart';

import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:delivery_apps/features/home/widget/categories_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  final BackendService _backendService = BackendService();
  List<Product> products = [];
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
      // Load both foods and favorites to sync UI states
      final List<FoodModel> foods =
          await _backendService.getFoods(categoryId: categoryId);
      
      List<Product> favs = [];
      try {
        favs = await _backendService.getFavorites();
      } catch (_) {
        // Ignore fav fetch errors so products still load if not logged in
      }
      final favIds = favs.map((e) => e.id).toSet();

      final loadedProducts = foods.map((e) {
        final p = Product.fromJson({
          'id': e.id,
          'name': e.name,
          'image_url': e.imageUrl ?? '',
          'price': e.price,
          'description': e.description ?? '',
          'restaurant_id': e.restaurantId,
          'restaurant_name': e.restaurantName,
        });

        // Sync favorite states with backend
        if (favIds.contains(p.id)) {
          p.isFavorite.add('local'); // Legacy 'local' flag used in UI
        }

        return p;
      }).toList();

      if (!mounted) return;
      setState(() {
        products = loadedProducts;
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint("Lỗi khi tải sản phẩm: $e");
      if (!mounted) return;
      setState(() {
        products = [];
        isLoading = false;
      });
    }
  }

  void _toggleFavorite(Product product) {
    if (!mounted) return;
    
    _backendService.toggleFavorite(int.parse(product.id)).catchError((e) {
      if (kDebugMode) debugPrint("Lỗi toggle backend favorite: $e");
    });
    
    setState(() {
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final current = products[index];
        final newFav = List<String>.from(current.isFavorite);
        const localId = 'local';
        if (newFav.contains(localId)) {
          newFav.remove(localId);
        } else {
          newFav.add(localId);
        }
        products[index] = Product(
          id: current.id,
          name: current.name,
          imageUrl: current.imageUrl,
          price: current.price,
          isFavorite: newFav,
          description: current.description,
          categoryId: current.categoryId,
        );
      }
    });
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
              : products.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Không có sản phẩm nào",
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
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  product: product,
                                  onToggleFavorite: _toggleFavorite,
                                ),
                              ),
                            ).then((_) => _loadProducts());
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
                                        child: product.imageUrl.isEmpty
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : CachedNetworkImage(
                                                imageUrl: product.imageUrl,
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
                                      Padding(
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
                                                _toggleFavorite(product),
                                            icon: Icon(
                                              product.isLikedBy('local')
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: product.isLikedBy('local')
                                                  ? Colors.red
                                                  : Colors.grey,
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
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
                                        product.name,
                                        style: AppTextStyle.bodyBold(context,
                                            fontSize: 13,
                                            color: AppColor.textTitle(context)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      if (product.restaurantName != null)
                                        Text(
                                          product.restaurantName!,
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
                                            "\$${product.price}",
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
                                                try {
                                                  await _backendService
                                                      .addToCart(CartItem(
                                                    id: '', // Backend DB will auto-generate
                                                    productId: product.id,
                                                    restaurantId:
                                                        product.categoryId ??
                                                            '',
                                                    name: product.name,
                                                    imageUrl: product.imageUrl,
                                                    price: product.price,
                                                    quantity: "1",
                                                  ));
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              "Đã thêm vào giỏ hàng")),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content:
                                                              Text("Lỗi: $e"),
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
