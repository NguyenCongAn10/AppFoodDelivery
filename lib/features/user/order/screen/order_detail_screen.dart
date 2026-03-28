import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/providers/order_realtime_provider.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/user/order/widget/order_tracking_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _order;
  late OrderRealtimeProvider _realtimeProvider;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    // Save reference for safe dispose
    _realtimeProvider = context.read<OrderRealtimeProvider>();
    _realtimeProvider.subscribe();
  }

  @override
  void dispose() {
    _realtimeProvider.unsubscribe();
    super.dispose();
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.CONFIRMED:
        return Colors.blue;
      case OrderStatus.DELIVERING:
        return Colors.purple;
      case OrderStatus.COMPLETED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return 'Pending';
      case OrderStatus.CONFIRMED:
        return 'Confirmed';
      case OrderStatus.DELIVERING:
        return 'Delivering';
      case OrderStatus.COMPLETED:
        return 'Completed';
      case OrderStatus.CANCELLED:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Update local order when a realtime payload matches this order's ID
    final payload = context.select<OrderRealtimeProvider, Map<String, dynamic>?>(
      (p) => p.latestPayload,
    );
    if (payload != null && payload['id'] == _order.id) {
      try {
        _order = OrderModel.fromJson(payload);
      } catch (_) {}
    }

    final order = _order;
    final restaurant = order.restaurant;

    final resLat = restaurant?.latitude ?? 21.0285;
    final resLng = restaurant?.longitude ?? 105.8542;
    final destLat = order.deliveryLat ?? resLat;
    final destLng = order.deliveryLng ?? resLng;
    final shipperLat = order.shipperLat ?? (resLat + destLat) / 2;
    final shipperLng = order.shipperLng ?? (resLng + destLng) / 2;

    final distance = calculateDistance(resLat, resLng, destLat, destLng);

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  RoundIconCircle(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text('Order #${order.id}',
                      style: AppTextStyle.bodyBold(context,
                          color: AppColor.textTitle(context), fontSize: 18)),
                  const Spacer(),
                  const SizedBox(width: 40), // Placeholder for balance
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Section
                  OrderTrackingMap(
                    restaurantLat: restaurant?.latitude ?? 21.0285,
                    restaurantLng: restaurant?.longitude ?? 105.8542,
                    deliveryLat: order.deliveryLat,
                    deliveryLng: order.deliveryLng,
                    isDelivering: order.status == OrderStatus.DELIVERING,
                    shipperLat: order.shipperLat,
                    shipperLng: order.shipperLng,
                  ),

                  const SizedBox(height: 25),

                  // Order Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Order Status", style: AppTextStyle.bodyBold(context, fontSize: 18)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusLabel(order.status),
                          style: TextStyle(
                              color: _statusColor(order.status),
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Location Card
                  _buildSectionCard(
                    context,
                    title: "Delivery Details",
                    child: Column(
                      children: [
                        _buildLocationRow(
                          context,
                          icon: Icons.store_mall_directory_outlined,
                          title: "From Restaurant",
                          subtitle: restaurant?.restaurantName ?? "Restaurant",
                          address: restaurant?.address ?? "Unknown Address",
                          color: AppColor.primary(context),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              child: VerticalDivider(
                                  thickness: 1,
                                  width: 20,
                                  radius: BorderRadius.circular(10),
                                  color: AppColor.textTitle(context)),
                            ),
                            Text(
                              '${distance.toStringAsFixed(2)} km',
                              style: AppTextStyle.body(context,
                                  fontSize: 12,
                                  color: AppColor.textSecondary(context)),
                            ),
                            SizedBox(
                              height: 20,
                              child: VerticalDivider(
                                  radius: BorderRadius.circular(10),
                                  thickness: 1,
                                  width: 20,
                                  color: AppColor.textTitle(context)),
                            ),
                          ],
                        ),
                        _buildLocationRow(
                          context,
                          icon: Icons.location_on_outlined,
                          title: "To Your Address",
                          subtitle: order.user?.name ?? "Customer",
                          address: order.deliveryAddress ?? "No address provided",
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSectionCard(
                    context,
                    title: "Order Items",
                    child: Column(
                      children: [
                        ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColor.inputFill(context),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text("${item.quantity}x",
                                    style: AppTextStyle.bodyBold(context,
                                        color: AppColor.primary(context), fontSize: 14)),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.food?.name ?? "Food Item",
                                        style: AppTextStyle.bodyBold(context, fontSize: 16)),
                                    if (item.food?.description != null)
                                      Text(item.food!.description!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle.body(context,
                                              color: AppColor.textSecondary(context),
                                              fontSize: 12)),
                                        if (item.selectedOptions != null &&
                                            item.selectedOptions!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                                item.selectedOptions!
                                                    .map((e) => e.name)
                                                    .join(", "),
                                                style: AppTextStyle.body(
                                                    context,
                                                    color: AppColor.primary(
                                                        context),
                                                    fontSize: 12)),
                                          ),
                                  ],
                                ),
                              ),
                              Text("\$${item.price.toStringAsFixed(2)}",
                                  style: AppTextStyle.bodyBold(context, fontSize: 16)),
                            ],
                          ),
                        )),
                        const Divider(height: 30),
                        _buildPriceRow(context, "Items Subtotal", order.totalPrice),
                        _buildPriceRow(context, "Total", order.totalPrice, isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyle.bodyBold(context, fontSize: 17)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLocationRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String address,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTextStyle.body(context,
                      color: AppColor.textSecondary(context), fontSize: 12)),
              Text(subtitle, style: AppTextStyle.bodyBold(context, fontSize: 15)),
              Text(address,
                  style: AppTextStyle.body(context,
                      color: AppColor.textSecondary(context), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? AppTextStyle.bodyBold(context, fontSize: 18)
                  : AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 15)),
          Text("\$${amount.toStringAsFixed(2)}",
              style: isTotal
                  ? AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 18)
                  : AppTextStyle.bodyBold(context, fontSize: 15)),
        ],
      ),
    );
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLng = (lng2 - lng1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final d = 6378.1 * c;
    return d;
  }
}