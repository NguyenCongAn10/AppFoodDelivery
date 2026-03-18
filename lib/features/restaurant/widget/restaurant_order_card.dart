import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

enum RestaurantOrderStatus { pending, accepted, preparing, ready, completed, cancelled }

class RestaurantOrderItem {
  final String name;
  final int quantity;
  final double price;

  const RestaurantOrderItem({required this.name, required this.quantity, required this.price});
}

class RestaurantOrder {
  final String orderId;
  final String orderNumber;
  final String time;
  final String customerName;
  final String? customerPhone;
  final String address;
  final List<RestaurantOrderItem> items;
  final double totalBill;
  final String paymentMode;
  RestaurantOrderStatus status;

  RestaurantOrder({
    required this.orderId,
    required this.orderNumber,
    required this.time,
    required this.customerName,
    this.customerPhone,
    required this.address,
    required this.items,
    required this.totalBill,
    required this.paymentMode,
    this.status = RestaurantOrderStatus.pending,
  });
}

class RestaurantOrderCard extends StatelessWidget {
  final RestaurantOrder order;
  final VoidCallback onMoreTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReady;

  const RestaurantOrderCard({
    super.key,
    required this.order,
    required this.onMoreTap,
    this.onAccept,
    this.onReject,
    this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == RestaurantOrderStatus.pending;
    final isAccepted = order.status == RestaurantOrderStatus.accepted ||
        order.status == RestaurantOrderStatus.preparing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Text(
                  '${order.orderNumber}  |  ${order.time}',
                  style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 13),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onMoreTap,
                  child: Icon(Icons.more_vert, color: AppColor.textSecondary(context)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Text(
              order.customerName,
              style: AppTextStyle.body(context, color: AppColor.primary(context), fontSize: 13),
            ),
          ),
          // Items
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Text('${item.quantity} X  ', style: AppTextStyle.body(context, fontSize: 14)),
                  Expanded(child: Text(item.name, style: AppTextStyle.body(context, fontSize: 14))),
                  Text(
                    'Rs. ${item.price.toStringAsFixed(0)}',
                    style: AppTextStyle.bodyBold(context, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Total & Payment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Total Bill: Rs. ${order.totalBill.toStringAsFixed(0)}',
                  style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)),
                ),
                const Spacer(),
                Text(
                  'Payment Mode: ${order.paymentMode}',
                  style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Action Buttons
          if (isPending) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      onTap: onAccept,
                      label: 'ACCEPT',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      onTap: onReject,
                      label: 'REJECT',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isAccepted) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildActionButton(
                onTap: onReady,
                label: 'ORDER READY',
                color: Colors.green,
                expanded: true,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: order.status == RestaurantOrderStatus.completed
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    order.status == RestaurantOrderStatus.completed ? 'COMPLETED' : 'CANCELLED',
                    style: TextStyle(
                      color: order.status == RestaurantOrderStatus.completed ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required String label,
    required Color color,
    bool expanded = false,
  }) {
    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
