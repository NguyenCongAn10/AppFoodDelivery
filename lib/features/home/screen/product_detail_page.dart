import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/widgets/top_background_clipper.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/models/product.dart';
import 'package:delivery_apps/core/services/local_cart_service.dart';
import 'package:delivery_apps/features/cart/screen/cart_screen.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product)? onToggleFavorite;

  const ProductDetailPage({
    super.key,
    required this.product,
    this.onToggleFavorite,
  });

  @override
  State<ProductDetailPage> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductDetailPage> {
  final LocalCartService _cartService = LocalCartService();
  late bool isLiked;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
    isLiked = widget.product.isLikedBy('local');
  }

  double get totalPrice {
    return (double.tryParse(widget.product.price) ?? 0.0) * itemCount;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopBackgroundClipper(),
            child: Container(
              height: 350,
              color: AppColor.primary(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      RoundIconCircle(
                        icon: Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppColor.textTitle(context)),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      RoundIconCircle(
                        icon: Icon(Icons.favorite,
                            size: 18,
                            color: isLiked
                                ? Colors.red
                                : AppColor.textSecondary(context)),
                        onTap: () {
                          widget.onToggleFavorite?.call(widget.product);
                          setState(() => isLiked = !isLiked);
                        },
                      ),
                      const SizedBox(width: 8),
                      RoundIconCircle(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CartScreen())),
                        icon: Icon(Icons.shopping_cart_outlined,
                            size: 18, color: AppColor.textTitle(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: CircleAvatar(
                    radius: 130,
                    backgroundImage: widget.product.imageUrl.isNotEmpty
                        ? NetworkImage(widget.product.imageUrl)
                        : null,
                    child: widget.product.imageUrl.isEmpty
                        ? const CircularProgressIndicator()
                        : null,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.bodyBold(context,
                            fontSize: 25, color: AppColor.textTitle(context)),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.primary(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (itemCount > 0) setState(() => itemCount--);
                              },
                              child: const Icon(Icons.remove, color: Colors.white),
                            ),
                            const Spacer(),
                            Text("$itemCount",
                                style: AppTextStyle.body(context,
                                    color: Colors.white)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => setState(() => itemCount++),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text("Description",
                    style: AppTextStyle.bodyBold(context,
                        color: AppColor.textTitle(context))),
                const SizedBox(height: 10),
                Text(widget.product.description,
                    style: AppTextStyle.body(context,
                        color: AppColor.textTitle(context))),
                const SizedBox(height: 200),
                Container(
                  height: media.height * 0.06,
                  padding: const EdgeInsets.only(left: 15, right: 8),
                  decoration: BoxDecoration(
                    color: AppColor.primary(context),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Text("\$${totalPrice.toStringAsFixed(2)}",
                          style: AppTextStyle.bodyBold(context,
                              color: Colors.white)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          await _cartService.addToCart(CartItem(
                            id: widget.product.id,
                            productId: widget.product.id,
                            restaurantId: widget.product.categoryId ?? '',
                            name: widget.product.name,
                            imageUrl: widget.product.imageUrl,
                            price: totalPrice.toStringAsFixed(2),
                            quantity: itemCount.toString(),
                          ));

                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColor.container(context),
                              title: Text(
                                "Đã thêm sản phẩm vào giỏ hàng",
                                style: AppTextStyle.body(context,
                                    color: AppColor.textTitle(context)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.push(ctx,
                                      MaterialPageRoute(
                                          builder: (_) => CartScreen())),
                                  child: Text("Go to cart",
                                      style: AppTextStyle.bodyBold(context,
                                          color: AppColor.primary(context))),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text("Ok",
                                      style: AppTextStyle.bodyBold(context,
                                          color: AppColor.primary(context))),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColor.container(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text("Add to cart",
                              style: AppTextStyle.bodyBold(context,
                                  fontSize: 15,
                                  color: AppColor.textTitle(context))),
                        ),
                      ),
                    ],
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
