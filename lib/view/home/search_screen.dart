import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/product_view/productDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false; // Biến trạng thái loading

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchAndFilterProducts);
    _fetchAllProducts();
  }

  Future<void> _fetchAllProducts() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading
    });

    try {
      final categories = await _firebaseService.getCategories();
      List<Product> allProducts = [];

      for (var category in categories) {
        final products =
            await _firebaseService.getProductByCategory(category.id);

        // Gán categoryId cho từng product
        for (var product in products) {
          product.categoryId = category.id;
        }

        allProducts.addAll(products);
      }

      setState(() {
        _products = allProducts;
        _filteredProducts = allProducts;
      });
    } catch (e) {
      print("Lỗi khi lấy tất cả sản phẩm: $e");
    } finally {
      setState(() {
        _isLoading = false; // Kết thúc loading
      });
    }
  }

  Future<void> _searchAndFilterProducts() async {
    setState(() {
      _isLoading = true; // Bắt đầu loading cho tìm kiếm
    });

    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query);
      }).toList();
      _isLoading = false; // Kết thúc loading
    });
  }

  Future<void> _toggleFavorite(Product product) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("Chưa đăng nhập, không thể cập nhật yêu thích");
      return;
    }
    if (product.categoryId == null) {
      print("Không có categoryId để cập nhật favorite");
      return;
    }

    try {
      await _firebaseService.updateFavoriteStatus(
        product.categoryId!,
        product.id,
        product.isLikedByCurrentUser,
      );

      // Cập nhật lại danh sách sản phẩm sau khi toggle
      await _fetchAllProducts();
      _searchAndFilterProducts();
    } catch (e) {
      print("Lỗi cập nhật trạng thái yêu thích: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: TColor.main, width: 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: "Search your food",
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 12),
                              ),
                              cursorColor: TColor.main,
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _searchAndFilterProducts();
                            },
                            icon: const Icon(Icons.search),
                            iconSize: 27,
                            color: TColor.main,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Xử lý khi nhấn biểu tượng camera (nếu cần)
                            },
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: TColor.main,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 27,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredProducts.isEmpty
                      ? const Center(child: Text("No products found"))
                      : GridView.builder(
                          padding: const EdgeInsets.all(10),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product,
                                      onToggleFavorite: (product) {
                                        _toggleFavorite(product);
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                  width: 180,
                                  height: 200,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: 180,
                                            height: 180,
                                            decoration: BoxDecoration(
                                                color: TColor.textfield,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          )),
                                      Positioned(
                                          top: 0,
                                          child: ClipOval(
                                            child: Image.network(
                                              product.imageUrl,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                      Positioned(
                                        top: 5,
                                        right: 27,
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundColor: TColor.main,
                                          child: GestureDetector(
                                            onTap: () {
                                              _firebaseService.addToCart(
                                                  CartItem(
                                                      id: product.id,
                                                      productId: product.id,
                                                      name: product.name,
                                                      imageUrl:
                                                          product.imageUrl,
                                                      price: product.price,
                                                      quantity: "1"));
                                            },
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 150),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            NormalText(
                                                color: Colors.black,
                                                txt: product.name),
                                            const SizedBox(height: 5),
                                            NormalTextBold(
                                                color: TColor.secondaryText,
                                                txt: "\$${product.price}")
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
