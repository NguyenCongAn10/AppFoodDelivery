import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/home/categories_slider.dart';
import 'package:delivery_apps/view/product_view/productDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductHome extends StatefulWidget {
  const ProductHome({super.key});

  @override
  State<ProductHome> createState() => _ProductHomeState();
}

class _ProductHomeState extends State<ProductHome> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> products = [];
  String selectedCategory = "cat1";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    print("Đang tải sản phẩm cho danh mục: $selectedCategory");
    try {
      final loadedProducts =
          await _firebaseService.getProductByCategory(selectedCategory);
      print("Số sản phẩm tải được: ${loadedProducts.length}");
      setState(() {
        products = loadedProducts;
      });
    } catch (e) {
      print("Lỗi khi tải sản phẩm: $e");
      setState(() {
        products = [];
      });
    }
  }

  void _toggleFavorite(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("Không có người dùng đăng nhập");
      return;
    }

    final isLiked = product.isLikedByCurrentUser;
    final newFavoriteList = List<String>.from(product.isFavorite);
    if (isLiked) {
      newFavoriteList.remove(uid);
    } else {
      newFavoriteList.add(uid);
    }

    try {
      await _firebaseService.updateFavoriteStatus(
          selectedCategory, product.id, isLiked);
      print("Cập nhật trạng thái thành công cho sản phẩm: ${product.id}");

      // Cập nhật danh sách products để đổi màu ngay
      setState(() {
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index] = Product(
            id: product.id,
            name: product.name,
            imageUrl: product.imageUrl,
            price: product.price,
            isFavorite: newFavoriteList,
            description: product.description,
          );
        }
      });
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái yêu thích: $e");
    }
  }

  void _onCategorySelected(String categoryId) {
    setState(() {
      selectedCategory = categoryId;
    });
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Column(
      children: [
        CategoriesSlider(onCategorySelected: _onCategorySelected),
        const SizedBox(height: 20),
        Row(
          children: [
            NormalTextBold(color: TColor.primary, txt: "Top Picks"),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.arrow_forward_ios_rounded),
            ),
          ],
        ),
        Container(
          width: media.width,
          height: 180,
          child: products.isEmpty
              ? Center(
                  child: NormalText(
                      color: Colors.red, txt: "Không có sản phẩm nào"),
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
                        ).then((_) {
                          _loadProducts(); // Tải lại danh sách khi quay lại
                        });
                      },
                      child: Card(
                        color: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(alignment: Alignment.topRight, children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    product.imageUrl.isNotEmpty
                                        ? product.imageUrl
                                        : "https://i.imgur.com/qom0c1c.jpg",
                                    height: 100,
                                    width: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.error, size: 50);
                                    },
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
                                    onPressed: () {
                                      _toggleFavorite(product);
                                    },
                                    icon: const Icon(Icons.favorite),
                                    padding: EdgeInsets.zero,
                                    color: product.isLikedByCurrentUser
                                        ? Colors.red
                                        : Colors.grey,
                                    iconSize: 20,
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  NormalTextBold(
                                    color: TColor.primary,
                                    txt: product.name,
                                    size: 15,
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: TColor.main,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: IconButton(
                                      onPressed: () {},
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
                                child: NormalTextBold(
                                  color: TColor.secondaryText,
                                  txt: "\$${product.price}",
                                  size: 15,
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
