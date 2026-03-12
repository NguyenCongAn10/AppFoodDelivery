import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/widgets/round_textfield.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BackendService _backendService = BackendService();

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
                'restaurant_name': e.restaurantName,
              }))
          .toList();
      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      if (kDebugMode) debugPrint("Lỗi khi lấy sản phẩm: $e");
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
                    
                    child: RoundTextField(
                      textEditingController: _searchController,
                      hint: "Search your food",
                      preicon: Icon(
                        Icons.search,
                        color: AppColor.textTitle(context),
                      ),
                      sufIcon: false,
                      obscureText: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColor.primary(context),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        size: 24, color: Colors.white),
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
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Positioned(
                                      bottom: 15,
                                      child: Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: AppColor.container(context),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: product.imageUrl,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const SizedBox(
                                            width: 120,
                                            height: 120,
                                            child: Center(
                                                child: Icon(Icons.error,
                                                    size: 50)),
                                          ),
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
                                          onTap: () async {
                                            try {
                                              await _backendService.addToCart(CartItem(
                                                id: '',
                                                productId: product.id,
                                                restaurantId: product.categoryId ?? '',
                                                name: product.name,
                                                imageUrl: product.imageUrl,
                                                price: product.price,
                                                quantity: "1",
                                              ));
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Đã thêm vào giỏ hàng")),
                                                );
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                          child: const Icon(Icons.add,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 150),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(product.name,
                                              style: AppTextStyle.body(context,
                                                  color: AppColor.textBody(
                                                      context))),
                                          const SizedBox(height: 2),
                                          if (product.restaurantName != null)
                                            Text(product.restaurantName!,
                                                style: AppTextStyle.body(
                                                    context,
                                                    color:
                                                        AppColor.textSecondary(
                                                            context),
                                                    fontSize: 12),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
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
