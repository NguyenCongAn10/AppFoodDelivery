import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/common_widget/round_button.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/main_tabview/home_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> listCartItem = [];
  FirebaseService _firebaseService = FirebaseService();
  double subTotal = 0.0;
  @override
  void initState() {
    super.initState();
    _loadListCartItem();
    subTotal = _pureSubTotal();
  }

  void _loadListCartItem() async {
    try {
      final _loadListCartItem = await _firebaseService.getCartItem();
      setState(() {
        listCartItem = _loadListCartItem;
      });
    } catch (e) {
      throw Exception("Loi hki tai gion hang: $e");
    }
  }

  double _pureSubTotal() {
    double subTotalTemp = 0.0;
    for (var item in listCartItem) {
      final quantity = double.tryParse(item.quantity) ?? 0.0;
      final price = double.tryParse(item.price) ?? 0.0;
      subTotalTemp += quantity * price;
    }
    return subTotalTemp;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: TColor.textfield,
        body: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SafeArea(
                child: Row(
                  children: [
                    RoundIconCircle(
                      icon: Icon(Icons.arrow_back_ios_new),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ));
                      },
                    ),
                    Spacer(),
                    NormalText(color: TColor.primary, txt: "Cart"),
                    Spacer(),
                    RoundIconCircle(
                      icon: Icon(Icons.close),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: Container(
                    width: media.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 20, top: 5),
                      children: [
                        ...listCartItem.map((item) => Container(
                              width: media.width,
                              height: 120,
                              child: Card(
                                margin: EdgeInsets.all(8),
                                shadowColor: Colors.transparent,
                                color: TColor.textfield,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          NormalText(
                                              color: Colors.black,
                                              txt: item.name),
                                          SizedBox(height: 8),
                                          NormalTextBold(
                                              color: TColor.secondaryText,
                                              txt: "\$${item.price}"),
                                        ],
                                      ),
                                      Spacer(),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: TColor.main,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: const Icon(Icons.add,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: NormalText(
                                                color: Colors.black,
                                                txt: "${item.quantity}"),
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  color: TColor.main,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: const Icon(Icons.remove,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(Icons.discount_outlined),
                              NormalText(
                                color: Colors.grey,
                                txt: "Voicher",
                                size: 15,
                              ),
                              Spacer(),
                              Container(
                                width: 80,
                                height: 35,
                                decoration: BoxDecoration(
                                    color: TColor.main,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: NormalText(
                                    color: Colors.white,
                                    txt: "Apply",
                                    size: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              NormalText(
                                  color: Colors.grey,
                                  size: 17,
                                  txt: "Subtotal"),
                              Spacer(),
                              NormalText(
                                  color: Colors.grey,
                                  txt: "\$${_pureSubTotal()}")
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              NormalText(
                                  color: Colors.grey,
                                  size: 17,
                                  txt: "Discount"),
                              Spacer(),
                              NormalText(color: Colors.grey, txt: "")
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              NormalText(
                                  color: Colors.grey,
                                  size: 17,
                                  txt: "Shipping"),
                              Spacer(),
                              NormalText(color: Colors.grey, txt: "")
                            ],
                          ),
                        ),
                        DottedLine(
                          dashColor: TColor.main,
                          lineThickness: 1.5,
                          dashGapLength: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              NormalText(
                                  color: Colors.grey, size: 17, txt: "Total"),
                              Spacer(),
                              NormalText(color: Colors.grey, txt: "")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: RoundButton(
                              txt: NormalTextBold(
                                color: Colors.white,
                                txt: "Delivery",
                                size: 17,
                              ),
                              color: TColor.main,
                              onpress: () {}),
                        ),
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}
