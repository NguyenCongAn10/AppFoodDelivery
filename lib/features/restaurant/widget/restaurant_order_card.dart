import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:delivery_apps/core/models/order_model.dart';

class RestaurantOrderCard extends StatelessWidget {
  final OrderModel order;
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
    final isPending = order.status == OrderStatus.PENDING;
    final isAccepted = order.status == OrderStatus.CONFIRMED;

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
                  '${order.id.toString().padLeft(4, '0')}  |  ${DateFormat('hh:mm a').format(order.createdAt)}',
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
              order.user?.name ?? 'Guest',
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
                  Expanded(child: Text(item.food?.name ?? 'Item', style: AppTextStyle.body(context, fontSize: 14))),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(0)}',
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
                  'Total Bill: \$${order.totalPrice.toStringAsFixed(0)}',
                  style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)),
                ),
                const Spacer(),
                Text(
                  'Payment Mode: ${order.paymentMethod ?? 'CASH'}',
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
              child: order.shipperId == null 
               ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'WAITING FOR SHIPPER',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
               : _buildActionButton(
                onTap: onReady,
                label: 'ORDER READY (HANDOVER)',
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
                  color: order.status == OrderStatus.COMPLETED
                      ? Colors.green.withValues(alpha: 0.1)
                      : (order.status == OrderStatus.CANCELLED ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    order.status.name.toUpperCase(),
                    style: TextStyle(
                      color: order.status == OrderStatus.COMPLETED ? Colors.green : (order.status == OrderStatus.CANCELLED ? Colors.red : Colors.blue),
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
