import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/home/screen/product_detail_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavouriteScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const FavouriteScreen({super.key, this.onBackToHome});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final BackendService _backendService = BackendService();
  List<Product> favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() => _isLoading = true);
    try {
      final all = await _backendService.getFavorites();

      if (!mounted) return;
      setState(() {
        favoriteProducts = all;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Lỗi khi tải sản phẩm yêu thích: $e');
      if (!mounted) return;
      setState(() {
        favoriteProducts = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    try {
      await _backendService.toggleFavorite(int.parse(product.id));
      _loadFavoriteProducts(); // Reload list after removal
    } catch (e) {
      if (kDebugMode) debugPrint('Lỗi xoá yêu thích trên backend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
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
                    onTap: () {
                      if (widget.onBackToHome != null) {
                        widget.onBackToHome!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const Spacer(),
                  Text("Your Favorite",
                      style: AppTextStyle.body(context,
                          color: AppColor.textTitle(context))),
                  const Spacer(),
                  const SizedBox(width: 35),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                width: media.width,
                decoration: BoxDecoration(
                  color: AppColor.inputFill(context),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : favoriteProducts.isEmpty
                        ? Center(
                            child: Text(
                              "Không có sản phẩm yêu thích",
                              style: AppTextStyle.body(context,
                                  color: Colors.red),
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
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(
                                      product: product,
                                      onToggleFavorite: _toggleFavorite,
                                    ),
                                  ),
                                ).then((_) => _loadFavoriteProducts()),
                                child: Card(
                                  color: AppColor.container(context),
                                  child: Column(
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
                                                errorBuilder: (_, __, ___) =>
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
                                                  color: AppColor.container(
                                                      context),
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: IconButton(
                                                  onPressed: () =>
                                                      _toggleFavorite(product),
                                                  icon: const Icon(
                                                      Icons.favorite),
                                                  padding: EdgeInsets.zero,
                                                   color: Colors.red,
                                                  iconSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(product.name,
                                                  style: AppTextStyle.bodyBold(
                                                      context,
                                                      fontSize: 15,
                                                      color: AppColor.textTitle(
                                                          context))),
                                              const SizedBox(height: 4),
                                              if (product.restaurantName !=
                                                  null)
                                                Text(product.restaurantName!,
                                                    style: AppTextStyle.body(
                                                      context,
                                                      fontSize: 13,
                                                    )),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "\$${product.price}",
                                                    style:
                                                        AppTextStyle.bodyBold(
                                                            context,
                                                            fontSize: 15,
                                                            color: AppColor
                                                                .textAccent(
                                                                    context)),
                                                  ),
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color: AppColor.primary(
                                                          context),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () async {
                                                        try {
                                                          await _backendService
                                                              .addToCart(
                                                            CartItem(
                                                              id: '', // Backend DB will auto-generate
                                                              productId:
                                                                  product.id,
                                                              restaurantId:
                                                                  product.categoryId ??
                                                                      '',
                                                              name:
                                                                  product.name,
                                                              imageUrl: product
                                                                  .imageUrl,
                                                              price:
                                                                  product.price,
                                                              quantity: "1",
                                                            ),
                                                          );
                                                          if (mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Đã thêm vào giỏ hàng!'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green),
                                                            );
                                                          }
                                                        } catch (e) {
                                                          if (mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Lỗi: $e'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      icon:
                                                          const Icon(Icons.add),
                                                      padding: EdgeInsets.zero,
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
    );
  }
}
