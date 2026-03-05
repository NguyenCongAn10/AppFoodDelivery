import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/services/local_cart_service.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BackendService _backendService = BackendService();
  final LocalCartService _localCartService = LocalCartService();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
    _fetchAllProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllProducts() async {
    setState(() => _isLoading = true);
    try {
      final foods = await _backendService.getFoods();
      final products = foods
          .map((e) => Product.fromJson({
                'id': e.id,
                'name': e.name,
                'image_url': e.imageUrl ?? '',
                'price': e.price,
                'description': e.description ?? '',
                'restaurant_id': e.restaurantId,
              }))
          .toList();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      debugPrint("Lỗi khi lấy sản phẩm: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
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
                        color: AppColor.container(context),
                        border: Border.all(
                            color: AppColor.primary(context), width: 1),
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
                              cursorColor: AppColor.primary(context),
                              style: TextStyle(
                                  fontSize: 17,
                                  color: AppColor.textBody(context)),
                            ),
                          ),
                          IconButton(
                            onPressed: _filterProducts,
                            icon: const Icon(Icons.search),
                            iconSize: 27,
                            color: AppColor.primary(context),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: AppColor.primary(context),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(25),
                                bottomRight: Radius.circular(25),
                              ),
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                size: 27, color: Colors.white),
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
                      ? Center(
                          child: Text("No products found",
                              style: AppTextStyle.body(context,
                                  color: AppColor.textBody(context))),
                        )
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
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailPage(product: product),
                                ),
                              ),
                              child: Container(
                                width: 180,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: AppColor.container(context),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: AppColor.inputFill(context),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: ClipOval(
                                        child: Image.network(
                                          product.imageUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 27,
                                      child: CircleAvatar(
                                        radius: 15,
                                        backgroundColor:
                                            AppColor.primary(context),
                                        child: GestureDetector(
                                          onTap: () =>
                                              _localCartService.addToCart(
                                                CartItem(
                                                  id: product.id,
                                                  productId: product.id,
                                                  restaurantId:
                                                      product.categoryId ?? '',
                                                  name: product.name,
                                                  imageUrl: product.imageUrl,
                                                  price: product.price,
                                                  quantity: "1",
                                                ),
                                              ),
                                          child: const Icon(Icons.add,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 150),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(product.name,
                                              style: AppTextStyle.body(context,
                                                  color: AppColor.textBody(
                                                      context))),
                                          const SizedBox(height: 5),
                                          Text("\$${product.price}",
                                              style: AppTextStyle.bodyBold(
                                                  context,
                                                  color: AppColor.textAccent(
                                                      context))),
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
        ),
      ),
    );
  }
}
