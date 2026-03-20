import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/core/widgets/round_button.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/user/cart/provider/cart_provider.dart';
import 'package:delivery_apps/features/user/home/screen/main_screen.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:delivery_apps/features/user/home/providers/user_address_provider.dart';
import 'package:delivery_apps/features/user/home/screen/user_address_screen.dart';
import 'package:delivery_apps/features/user/cart/widget/payment_method_bottom_sheet.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:delivery_apps/features/user/profile/screen/edit_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const CartScreen({super.key, this.onBackToHome});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  Future<void> _checkout(CartProvider cart, PaymentMethod method) async {
    if (cart.items.isEmpty) return;

    final restaurantId = cart.items.first.restaurantId;
    final restaurantIdInt = int.tryParse(restaurantId) ?? 0;
    if (restaurantIdInt == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Cannot checkout: restaurant info missing. Please re-add items.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final items = cart.items
          .map((item) => {
                'food_id': int.tryParse(item.productId) ?? 0,
                'quantity': int.tryParse(item.quantity) ?? 1,
                'selected_options': item.selectedOptions.map((o) => o.toJson()).toList(),
              })
          .toList();

      final addressProvider =
          Provider.of<UserAddressProvider>(context, listen: false);
      final deliveryAddress = addressProvider.selectedAddress?.address;
      final lat = addressProvider.selectedAddress?.latitude;
      final lng = addressProvider.selectedAddress?.longitude;

      await BackendService().createOrder(
        restaurantId: restaurantIdInt,
        items: items.cast<Map<String, dynamic>>(),
        deliveryAddress: deliveryAddress,
        paymentMethod: method.toString().split('.').last.toUpperCase(),
        lat: lat,
        lng: lng,
      );

      await cart.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const MainScreen(
                    initialIndex: 3,
                  )),
        );
      }
    } catch (e) {
      if (mounted) {
        if (kDebugMode) debugPrint("Checkout error: $e");
      }
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: AppColor.container(context),
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
                        if (widget.onBackToHome != null) {
                          widget.onBackToHome!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    const Spacer(),
                    Text("Cart",
                        style: AppTextStyle.body(context,
                            color: AppColor.textTitle(context))),
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
                      color: AppColor.inputFill(context),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                    ),
                    child:
                        Consumer<CartProvider>(builder: (context, cart, child) {
                      return cart.items.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(50),
                                child: Text("Cart is empty"),
                              ),
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.only(bottom: 20, top: 5),
                              children: [
                                ...cart.items.map((item) {
                                  return Dismissible(
                                    key: Key(item.id),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) async {
                                      await cart.removeItem(item.id);
                                    },
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      margin: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.delete,
                                          color: Colors.white),
                                    ),
                                    child: Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        shadowColor: Colors.transparent,
                                        color: AppColor.container(context),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                child: Image.network(
                                                  item.imageUrl,
                                                  width: 90,
                                                  height: 90,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                          width: 90,
                                                          height: 90,
                                                          color: Colors.grey,
                                                          child: const Icon(
                                                              Icons.fastfood)),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item.name,
                                                      style: AppTextStyle.body(
                                                          context,
                                                          color:
                                                              AppColor.textBody(
                                                                  context)),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      "\$${item.price}",
                                                      style:
                                                          AppTextStyle.bodyBold(
                                                              context,
                                                              color: AppColor
                                                                  .textAccent(
                                                                      context)),
                                                    ),
                                                    if (item.selectedOptions
                                                        .isNotEmpty) ...[
                                                      const SizedBox(height: 4),
                                                      Wrap(
                                                        spacing: 4,
                                                        children:
                                                            item.selectedOptions
                                                                .map(
                                                                    (opt) =>
                                                                        Text(
                                                                          "+ ${opt.name} (\$${opt.price})",
                                                                          style: AppTextStyle.body(
                                                                              context,
                                                                              fontSize: 12,
                                                                              color: AppColor.textSecondary(context)),
                                                                        ))
                                                                .toList(),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () async {
                                                      int currentQuantity =
                                                          int.tryParse(item
                                                                  .quantity) ??
                                                              0;
                                                      await cart
                                                          .updateCartItemQuantity(
                                                              item.id,
                                                              (currentQuantity +
                                                                      1)
                                                                  .toString());
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              AppColor.primary(
                                                                  context),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: const Icon(
                                                          Icons.add,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8),
                                                    child: Text(
                                                        item.quantity,
                                                        style: AppTextStyle.body(
                                                            context,
                                                            color: AppColor
                                                                .textBody(
                                                                    context))),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      int currentQuantity =
                                                          int.tryParse(item
                                                                  .quantity) ??
                                                              0;
                                                      if (currentQuantity > 1) {
                                                        await cart
                                                            .updateCartItemQuantity(
                                                                item.id,
                                                                (currentQuantity -
                                                                        1)
                                                                    .toString());
                                                      } else {
                                                        await cart.removeItem(
                                                            item.id);
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              AppColor.primary(
                                                                  context),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10)),
                                                      child: const Icon(
                                                          Icons.remove,
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
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Row(
                                //     children: [
                                //       Text("Subtotal",
                                //           style: AppTextStyle.body(context,
                                //               color: AppColor.textSecondary(context),
                                //               fontSize: 17)),
                                //       const Spacer(),
                                //       Text("\$${cart.subTotal.toStringAsFixed(2)}",
                                //           style: AppTextStyle.body(context,
                                //               color: AppColor.textSecondary(context)))
                                //     ],
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.all(8.0),
                                //   child: Row(
                                //     children: [
                                //       Text("Shipping",
                                //           style: AppTextStyle.body(context,
                                //               color: AppColor.textSecondary(context),
                                //               fontSize: 17)),
                                //       const Spacer(),
                                //       Text("\$0.00",
                                //           style: AppTextStyle.body(context,
                                //               color: AppColor.textSecondary(context)))
                                //     ],
                                //   ),
                                // ),
                                Consumer<UserAddressProvider>(
                                  builder: (context, addressProvider, _) {
                                    final address =
                                        addressProvider.selectedAddress;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                "Delivery Address",
                                                style: AppTextStyle.bodyBold(
                                                    context,
                                                    fontSize: 16),
                                              ),
                                              const Spacer(),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ChangeAddressScreen(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  address == null
                                                      ? "Select"
                                                      : "Change",
                                                  style: TextStyle(
                                                      color: AppColor.primary(
                                                          context)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColor.inputFill(context),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on_outlined,
                                                    color: AppColor.primary(
                                                        context)),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    address?.address ??
                                                        "No address selected",
                                                    style: AppTextStyle.body(
                                                        context,
                                                        color: address == null
                                                            ? AppColor
                                                                .textSecondary(
                                                                    context)
                                                            : AppColor.textBody(
                                                                context)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                DottedLine(
                                  dashColor: AppColor.primary(context),
                                  lineThickness: 1.5,
                                  dashGapLength: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text("Total",
                                          style: AppTextStyle.body(context,
                                              color: AppColor.textSecondary(
                                                  context),
                                              fontSize: 17)),
                                      const Spacer(),
                                      Text(
                                          "\$${cart.subTotal.toStringAsFixed(2)}",
                                          style: AppTextStyle.bodyBold(context,
                                              color: AppColor.primary(context)))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 30, right: 30),
                                  child: _isCheckingOut
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : RoundButton(
                                          txt: Text("Delivery",
                                              style: AppTextStyle.bodyBold(
                                                  context,
                                                  color: Colors.white,
                                                  fontSize: 17)),
                                          color: AppColor.primary(context),
                                          onpress: () async {
                                            final addressProvider =
                                                Provider.of<UserAddressProvider>(
                                                    context,
                                                    listen: false);
                                            if (addressProvider
                                                    .selectedAddress ==
                                                null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please select a delivery address first'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            // Check for phone number
                                            try {
                                              final user = await BackendService().getMe();
                                              if (user.phone == null || user.phone!.trim().isEmpty) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Please add your phone number to proceed with delivery"),
                                                      backgroundColor: Colors.orange,
                                                    ),
                                                  );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                                                  );
                                                }
                                                return;
                                              }

                                              if (!context.mounted) return;
                                              showModalBottomSheet(
                                                context: context,
                                                backgroundColor:
                                                    Colors.transparent,
                                                isScrollControlled: true,
                                                builder: (context) =>
                                                    PaymentMethodBottomSheet(
                                                  onSelected: (method) {
                                                    _checkout(cart, method);
                                                  },
                                                ),
                                              );
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text("Error checking profile: $e"), backgroundColor: Colors.red),
                                              );
                                            }
                                          },
                                        ),
                                ),
                              ],
                            );
                    })),
              )
            ],
          ),
        ));
  }
}
