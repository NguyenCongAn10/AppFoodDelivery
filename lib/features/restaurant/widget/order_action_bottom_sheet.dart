import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_order_card.dart';
import 'package:flutter/material.dart';

import 'package:delivery_apps/core/models/order_model.dart';
import 'package:intl/intl.dart';

class OrderActionBottomSheet extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReady;

  const OrderActionBottomSheet({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onReady,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = order.status == OrderStatus.PENDING;
    final isAccepted = order.status == OrderStatus.CONFIRMED;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Title Row
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.toString().padLeft(4, '0')}',
                    style: AppTextStyle.bodyBold(context, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(order.createdAt),
                    style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)),
                  ),
                ],
              ),
              const Spacer(),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 20),
          // Customer Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColor.inputFill(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _infoRow(context, Icons.person_outline, 'Customer', order.user?.name ?? 'Guest'),
                if (order.user?.phone != null) ...[
                  const SizedBox(height: 10),
                  _infoRow(context, Icons.phone_outlined, 'Phone', order.user!.phone!),
                ],
                const SizedBox(height: 10),
                _infoRow(context, Icons.location_on_outlined, 'Address', order.deliveryAddress ?? 'Unknown'),
                const SizedBox(height: 10),
                _infoRow(context, Icons.payment_outlined, 'Payment', order.paymentMethod ?? 'CASH'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Order Items
          Text('Order Items', style: AppTextStyle.bodyBold(context, fontSize: 16)),
          const SizedBox(height: 10),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColor.primary(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.quantity}x',
                      style: AppTextStyle.bodyBold(context, fontSize: 13, color: AppColor.primary(context)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(item.food?.name ?? 'Item', style: AppTextStyle.body(context, fontSize: 14))),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: AppTextStyle.bodyBold(context, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Bill', style: AppTextStyle.bodyBold(context, fontSize: 15)),
              Text(
                '\$${order.totalPrice.toStringAsFixed(0)}',
                style: AppTextStyle.bodyBold(context, fontSize: 15, color: AppColor.primary(context)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action Buttons
          if (isPending) ...[
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'REJECT',
                    color: Colors.red,
                    onTap: () { Navigator.pop(context); onReject?.call(); },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionButton(
                    label: 'ACCEPT',
                    color: Colors.green,
                    onTap: () { Navigator.pop(context); onAccept?.call(); },
                  ),
                ),
              ],
            ),
          ] else if (isAccepted) ...[
            _ActionButton(
              label: 'MARK ORDER READY',
              color: Colors.green,
              onTap: () { Navigator.pop(context); onReady?.call(); },
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColor.primary(context)),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
        Expanded(child: Text(value, style: AppTextStyle.bodyBold(context, fontSize: 13))),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      OrderStatus.PENDING => ('Pending', Colors.orange),
      OrderStatus.CONFIRMED => ('Accepted', Colors.blue),
      OrderStatus.DELIVERING => ('Delivering', Colors.teal),
      OrderStatus.COMPLETED => ('Completed', Colors.green),
      OrderStatus.CANCELLED => ('Cancelled', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}
