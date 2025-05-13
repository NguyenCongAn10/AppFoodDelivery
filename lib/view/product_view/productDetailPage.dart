import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/TopBackgroundClipperProductDetail.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/common_widget/round_button_icon_login.dart';
import 'package:delivery_apps/model/product.dart';
import 'package:flutter/material.dart';

// class ProductDetailPage extends StatefulWidget {
//   final Product product;
//   const ProductDetailPage({super.key, required this.product});

//   @override
//   State<ProductDetailPage> createState() => _ProductViewState();
// }

// class _ProductViewState extends State<ProductDetailPage> {
//   final product = widget.product;
//   @override
//   Widget build(BuildContext context, dynamic product) {
//     return Scaffold(
//       body: Stack(children: [
//         ClipPath(
//           clipper: TopBackgroundClipper(),
//           child: Container(
//             height: 400,
//             color: TColor.textfield,
//           ),
//         ),
//         Padding(
//           padding: EdgeInsets.only(left: 10, right: 10),
//           child: Column(
//             children: [
//               SafeArea(
//                   child: Row(
//                 children: [
//                   RoundIconCircle(
//                     icon: const Icon(
//                       Icons.arrow_back_ios_new_rounded,
//                       size: 18,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const Spacer(),
//                   RoundIconCircle(
//                     icon: const Icon(
//                       Icons.favorite,
//                       size: 18,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 8,
//                   ),
//                   RoundIconCircle(
//                     icon: const Icon(
//                       Icons.shopping_cart_outlined,
//                       size: 18,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ],
//               )),
//               Center(
//                 child: CircleAvatar(
//                   radius: 100,
//                   backgroundImage: NetworkImage(product.imageUrl),
//                 ),
//               )
//             ],
//           ),
//         )
//       ]),
//     );
//   }
// }
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

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
                        icon: const Icon(
                          Icons.favorite,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      RoundIconCircle(
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
                    backgroundImage: NetworkImage(product.imageUrl),
                  ),
                ),
                Row(
                  children: [
                    NormalTextBold(
                      txt: product.name,
                      color: TColor.primary,
                      size: 25,
                    ),
                    Spacer(),
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
                                onTap: () {},
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                              ),
                              Spacer(),
                              NormalText(color: Colors.white, txt: "0"),
                              Spacer(),
                              GestureDetector(
                                onTap: () {},
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
                SizedBox(
                  height: 20,
                ),
                NormalTextBold(color: TColor.primary, txt: "Description"),
                SizedBox(
                  height: 10,
                ),
                NormalText(color: TColor.primary, txt: product.description)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
