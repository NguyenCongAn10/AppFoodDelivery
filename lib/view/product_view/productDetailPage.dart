import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/TopBackgroundClipperProductDetail.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/main_tabview/bottom_nav.dart';
import 'package:delivery_apps/view/main_tabview/cart_screen.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(Product) onToggleFavorite;
  const ProductDetailPage(
      {super.key, required this.product, required this.onToggleFavorite});

  @override
  State<ProductDetailPage> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductDetailPage> {
  FirebaseService _firebaseService = FirebaseService();
  late bool isLiked;
  int itemCount = 1;

  @override
  void initState() {
    super.initState();
    isLiked = widget.product.isLikedByCurrentUser;
  }

  double getTotalPrice() {
    final price = double.tryParse(widget.product.price) ?? 0.0;
    return price * itemCount;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final totalPrice = getTotalPrice().toStringAsFixed(2);
    return Scaffold(
      body: Stack(
        children: [
          ClipPath(
            clipper: TopBackgroundClipper(),
            child: Container(
              height: 350,
              color: TColor.textfield,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SafeArea(
                  child: Row(
                    children: [
                      RoundIconCircle(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      RoundIconCircle(
                        icon: Icon(
                          Icons.favorite,
                          size: 18,
                          color: isLiked ? Colors.red : Colors.black38,
                        ),
                        onTap: () {
                          widget.onToggleFavorite(widget.product);
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      RoundIconCircle(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CartScreen()));
                        },
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 18,
                          color: Colors.black87,
                        ),
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
                        ? CircularProgressIndicator()
                        : null,
                  ),
                ),
                Row(
                  children: [
                    NormalTextBold(
                      txt: widget.product.name,
                      color: TColor.primary,
                      size: 25,
                    ),
                    const Spacer(),
                    Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                            color: TColor.main,
                            borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (itemCount > 0) {
                                      itemCount--;
                                    }
                                  });
                                },
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              NormalText(
                                  color: Colors.white, txt: "$itemCount"),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    itemCount++;
                                  });
                                },
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                NormalTextBold(color: TColor.primary, txt: "Description"),
                const SizedBox(
                  height: 10,
                ),
                NormalText(
                    color: TColor.primary, txt: widget.product.description),
                const SizedBox(
                  height: 200,
                ),
                Container(
                    height: media.height * 0.06,
                    padding: EdgeInsets.only(left: 15, right: 8),
                    decoration: BoxDecoration(
                      color: TColor.main,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        NormalTextBold(
                            color: Colors.white, txt: "\$${totalPrice}"),
                        const Spacer(),
                        GestureDetector(
                          onTap: () async {
                            await _firebaseService.addToCart(CartItem(
                                id: widget.product.id,
                                productId: widget.product.id,
                                name: widget.product.name,
                                imageUrl: widget.product.imageUrl,
                                price: totalPrice,
                                quantity: itemCount.toString()));

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: NormalText(
                                        overflow: TextOverflow.visible,
                                        color: Colors.black,
                                        txt: "Da them san pham vao gio hang"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CartScreen(),
                                                ));
                                          },
                                          child: NormalTextBold(
                                              color: TColor.main,
                                              txt: "Go to cart")),
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: NormalTextBold(
                                              color: TColor.main, txt: "Ok"))
                                    ],
                                  );
                                });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 120,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: NormalTextBold(
                              color: TColor.primary,
                              txt: "Add to cart",
                              size: 15,
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
