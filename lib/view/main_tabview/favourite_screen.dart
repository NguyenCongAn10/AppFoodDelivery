import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/main_tabview/bottom_nav.dart';
import 'package:delivery_apps/view/product_view/productDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Product> favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() {
          favoriteProducts = [];
          _isLoading = false;
        });
        return;
      }

      final favoriteProductsList = await _firebaseService.getFavoriteProducts();
      setState(() {
        favoriteProducts = favoriteProductsList;
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải sản phẩm yêu thích: $e");
      setState(() {
        favoriteProducts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final categoryId = product.categoryId;
    if (categoryId == null) return;

    try {
      await _firebaseService.updateFavoriteStatus(
        categoryId,
        product.id,
        product.isLikedByCurrentUser,
      );

      setState(() {
        if (product.isLikedByCurrentUser) {
          favoriteProducts.removeWhere((p) => p.id == product.id);
        }
      });

      await _loadFavoriteProducts();
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái yêu thích: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.textfield,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      RoundIconCircle(
                        icon: const Icon(Icons.arrow_back_ios_new_outlined),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ButtomNavigation(),
                          ));
                        },
                      ),
                      const Spacer(),
                      NormalText(color: Colors.black, txt: "Your Favorite"),
                      const Spacer(),
                      const SizedBox(width: 35),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: media.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : favoriteProducts.isEmpty
                            ? Center(
                                child: NormalText(
                                  color: Colors.red,
                                  txt: "Không có sản phẩm yêu thích",
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: favoriteProducts.length,
                                itemBuilder: (context, index) {
                                  final product = favoriteProducts[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProductDetailPage(
                                            product: product,
                                            onToggleFavorite: _toggleFavorite,
                                          ),
                                        ),
                                      ).then((_) {
                                        _loadFavoriteProducts();
                                      });
                                    },
                                    child: Card(
                                      color: Colors.grey[200],
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Image.network(
                                                    product.imageUrl,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        const Icon(Icons.error,
                                                            size: 50),
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () =>
                                                          _toggleFavorite(
                                                              product),
                                                      icon: const Icon(
                                                          Icons.favorite),
                                                      padding: EdgeInsets.zero,
                                                      color: product
                                                              .isLikedByCurrentUser
                                                          ? Colors.red
                                                          : Colors.grey,
                                                      iconSize: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Expanded(
                                            flex: 1,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  NormalTextBold(
                                                    color: TColor.primary,
                                                    txt: product.name,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      NormalTextBold(
                                                        color: TColor
                                                            .secondaryText,
                                                        txt:
                                                            "\$${product.price}",
                                                        size: 15,
                                                      ),
                                                      Container(
                                                        width: 24,
                                                        height: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: TColor.main,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            _firebaseService
                                                                .addToCart(
                                                                    CartItem(
                                                              id: product.id,
                                                              productId:
                                                                  product.id,
                                                              name:
                                                                  product.name,
                                                              imageUrl: product
                                                                  .imageUrl,
                                                              price:
                                                                  product.price,
                                                              quantity: "1",
                                                            ));
                                                          },
                                                          icon: const Icon(
                                                              Icons.add),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          color: Colors.white,
                                                          iconSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
