import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/models/cart_item.dart';
import 'package:delivery_apps/core/services/local_cart_service.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/home/screen/main_screen.dart';
import 'package:delivery_apps/features/order/screen/order_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> listCartItem = [];
  final LocalCartService _localCartService = LocalCartService();
  final BackendService _backendService = BackendService();
  double subTotal = 0.0;
  bool _isCheckingOut = false;
  @override
  void initState() {
    super.initState();
    _loadListCartItem();
    subTotal = _pureSubTotal();
  }

  void _loadListCartItem() async {
    try {
      final _loadListCartItem = await _localCartService.getCart();
      if (mounted) {
        setState(() {
          listCartItem = _loadListCartItem;
        });
      }
    } catch (e) {
      throw Exception("Loi khi tai gio hang: $e");
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

  Future<void> _checkout() async {
    if (listCartItem.isEmpty) return;

    final restaurantId = listCartItem.first.restaurantId;
    final restaurantIdInt = int.tryParse(restaurantId) ?? 0;
    if (restaurantIdInt == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot checkout: restaurant info missing. Please re-add items.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      // Build items list
      final items = listCartItem.map((item) => {
        'food_id': int.tryParse(item.productId) ?? 0,
        'quantity': int.tryParse(item.quantity) ?? 1,
      }).toList();

      await _backendService.createOrder(
        restaurantId: restaurantIdInt,
        items: items.cast<Map<String, int>>(),
      );

      // Xóa cart sau khi đặt hàng thành công
      await _localCartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OrderScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColor.inputFill(context),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              SafeArea(
                child: Row(
                  children: [
                    RoundIconCircle(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ));
                      },
                    ),
                    const Spacer(),
                    Text("Cart", style: AppTextStyle.body(context, color: AppColor.textTitle(context))),
                    const Spacer(),
                    RoundIconCircle(
                      icon: const Icon(Icons.close),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Container(
                    width: media.width,
                    decoration: BoxDecoration(
                      color: AppColor.container(context),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 20, top: 5),
                      children: [
                        ...listCartItem.map((item) {
                          int index = listCartItem.indexOf(item);
                          return Container(
                            width: media.width,
                            height: 120,
                            child: Card(
                              margin: EdgeInsets.all(8),
                              shadowColor: Colors.transparent,
                              color: AppColor.inputFill(context),
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
                                        Text(
                                            item.name,
                                            style: AppTextStyle.body(context, color: AppColor.textBody(context)),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                            "\$${item.price}",
                                            style: AppTextStyle.bodyBold(context, color: AppColor.textAccent(context)),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            int currentQuantity =
                                                int.tryParse(item.quantity) ??
                                                    0;
                                            int newQuantity =
                                                currentQuantity + 1;
                                            setState(() {
                                              listCartItem[index].quantity =
                                                  newQuantity.toString();
                                            });
                                            await _localCartService
                                                .updateCartItem(item.id,
                                                    newQuantity.toString());
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: AppColor.primary(context),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: const Icon(Icons.add,
                                                color: Colors.white),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                              child: Text("${item.quantity}", style: AppTextStyle.body(context, color: AppColor.textBody(context))),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            int currentQuantity =
                                                int.tryParse(item.quantity) ??
                                                    0;
                                            if (currentQuantity > 1) {
                                              int newQuantity =
                                                  currentQuantity - 1;
                                              setState(() {
                                                listCartItem[index].quantity =
                                                    newQuantity.toString();
                                              });
                                              await _localCartService
                                                  .updateCartItem(item.id,
                                                      newQuantity.toString());
                                            } else {
                                              await _localCartService
                                                  .removeFromCart(item.id);
                                              setState(() {
                                                _loadListCartItem();
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                                color: AppColor.primary(context),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
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
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 20),
                          child: Row(
                            children: [
                              Icon(Icons.discount_outlined),
                              Text(
                                "Voucher",
                                style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 15),
                              ),
                              Spacer(),
                              Container(
                                width: 80,
                                height: 35,
                                decoration: BoxDecoration(
                                    color: AppColor.primary(context),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                      "Apply",
                                      style: AppTextStyle.body(context, color: Colors.white, fontSize: 15),
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
                                Text("Subtotal", style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 17)),
                              Spacer(),
                                Text("\$${_pureSubTotal().toStringAsFixed(2)}", style: AppTextStyle.body(context, color: AppColor.textSecondary(context)))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                                Text("Discount", style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 17)),
                                Spacer(),
                                Text("", style: AppTextStyle.body(context, color: AppColor.textSecondary(context)))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                                Text("Shipping", style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 17)),
                                Spacer(),
                                Text("", style: AppTextStyle.body(context, color: AppColor.textSecondary(context)))
                            ],
                          ),
                        ),
                        DottedLine(
                          dashColor: AppColor.primary(context),
                          lineThickness: 1.5,
                          dashGapLength: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                                Text("Total", style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 17)),
                              Spacer(),
                              Text("", style: AppTextStyle.body(context, color: AppColor.textSecondary(context)))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: _isCheckingOut
                              ? const Center(child: CircularProgressIndicator())
                              : RoundButton(
                                  txt: Text("Delivery", style: AppTextStyle.bodyBold(context, color: Colors.white, fontSize: 17)),
                                  color: AppColor.primary(context),
                                  onpress: _checkout,
                                ),
                        ),
                      ],
                    )),
              )
            ],
          ),
        ));
  }
}
