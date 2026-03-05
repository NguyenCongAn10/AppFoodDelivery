import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/local_cart_service.dart';
import 'package:delivery_apps/features/home/widget/categories_slider.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:flutter/material.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  final BackendService _backendService = BackendService();
  final LocalCartService _localCartService = LocalCartService();
  List<Product> products = [];
  String selectedCategory = "cat1";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final List<FoodModel> foods = await _backendService.getFoods();
      final loadedProducts = foods.map((e) => Product.fromJson({
        'id': e.id,
        'name': e.name,
        'image_url': e.imageUrl ?? '',
        'price': e.price,
        'description': e.description ?? '',
        'restaurant_id': e.restaurantId,
      })).toList();

      if (!mounted) return;
      setState(() => products = loadedProducts);
    } catch (e) {
      debugPrint("Lỗi khi tải sản phẩm: $e");
      if (!mounted) return;
      setState(() => products = []);
    }
  }

  void _toggleFavorite(Product product) {
    if (!mounted) return;
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
    _loadProducts();
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
            Text("Top Picks", style: AppTextStyle.bodyBold(context)),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
        SizedBox(
          width: media.width,
          height: 180,
          child: products.isEmpty
              ? Center(
                  child: Text(
                    "Không có sản phẩm nào",
                    style: AppTextStyle.body(context, color: Colors.red),
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
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
                      child: Card(
                        color: AppColor.inputFill(context),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: product.imageUrl.isEmpty
                                        ? const CircularProgressIndicator()
                                        : Image.network(
                                            product.imageUrl,
                                            height: 100,
                                            width: 180,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.error, size: 50),
                                          ),
                                  ),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      onPressed: () => _toggleFavorite(product),
                                      icon: const Icon(Icons.favorite),
                                      padding: EdgeInsets.zero,
                                      color: product.isLikedBy('local')
                                          ? Colors.red
                                          : Colors.grey,
                                      iconSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    product.name,
                                    style: AppTextStyle.bodyBold(context,
                                        fontSize: 15,
                                        color: AppColor.textTitle(context)),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColor.primary(context),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        _localCartService.addToCart(CartItem(
                                          id: product.id,
                                          productId: product.id,
                                          restaurantId: product.categoryId ?? '',
                                          name: product.name,
                                          imageUrl: product.imageUrl,
                                          price: product.price,
                                          quantity: "1",
                                        ));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Added to cart")),
                                        );
                                      },
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.add),
                                      color: Colors.white,
                                      iconSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "\$${product.price}",
                                  style: AppTextStyle.bodyBold(context,
                                      fontSize: 15,
                                      color: AppColor.textAccent(context)),
                                ),
                              ),
                            ],
                          ),
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
