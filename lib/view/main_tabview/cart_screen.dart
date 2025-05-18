import 'package:delivery_apps/common/color_extention.dart';
import 'package:delivery_apps/common_widget/normal_text.dart';
import 'package:delivery_apps/common_widget/normal_text_bold.dart';
import 'package:delivery_apps/common_widget/roundIconCircle.dart';
import 'package:delivery_apps/model/cartItem.dart';
import 'package:delivery_apps/server/firebase_service.dart';
import 'package:delivery_apps/view/main_tabview/home_screen.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> listCartItem = [];
  FirebaseService _firebaseService = FirebaseService();
  @override
  void initState() {
    super.initState();
    _loadListCartItem();
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: listCartItem.length,
                            itemBuilder: (context, index) {
                              final item = listCartItem[index];
                              return Container(
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
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          spacing: 15,
                                          children: [
                                            NormalText(
                                                color: Colors.black,
                                                txt: item.name),
                                            NormalTextBold(
                                                color: TColor.secondaryText,
                                                txt: "\$${item.price}"),
                                          ],
                                        ),
                                        Spacer(),
                                        Row(
                                          spacing: 8,
                                          children: [
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: TColor.main,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            NormalText(
                                                color: Colors.black,
                                                txt: "${item.quantity}"),
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    color: TColor.main,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: const Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
