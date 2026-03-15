
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/widgets/round_icon_circle.dart';
import 'package:delivery_apps/features/order/screen/order_detail_screen.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  const OrderScreen({super.key, this.onBackToHome});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final BackendService _backendService = BackendService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orders = await _backendService.getMyOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
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
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
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
                  Text('My Orders', style: AppTextStyle.body(context, color: AppColor.textTitle(context))),
                  const Spacer(),
                  RoundIconCircle(
                    icon: const Icon(Icons.refresh),
                    onTap: _loadOrders,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 50,
                                  color: AppColor.textSecondary(context)),
                              const SizedBox(height: 12),
                                Text(_errorMessage!, style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _loadOrders,
                                child: Text('Try again',
                                    style: TextStyle(
                                        color: AppColor.primary(context))),
                              ),
                            ],
                          ),
                        )
                      : _orders.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 60,
                                      color: AppColor.textSecondary(context)),
                                  const SizedBox(height: 12),
                                    Text(
                                    'No orders yet',
                                      style: AppTextStyle.body(context, color: AppColor.textSecondary(context), fontSize: 16),
                                    ),
                                ],
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadOrders,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailScreen(order: order),
                                      ));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: AppColor.container(context),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Header: Order ID + Status
                                            Row(
                                              children: [
                                                Text(
                                                  'Order #${order.id}',
                                                  style: AppTextStyle.bodyBold(
                                                      context,
                                                      color: AppColor.textTitle(
                                                          context),
                                                      fontSize: 16),
                                                ),
                                                const Spacer(),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _statusColor(
                                                            order.status)
                                                        .withValues(
                                                            alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Text(
                                                    _statusLabel(order.status),
                                                    style: TextStyle(
                                                      color: _statusColor(
                                                          order.status),
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (order.deliveryAddress != null &&
                                                order.deliveryAddress!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      size: 14,
                                                      color: AppColor
                                                          .textSecondary(
                                                              context)),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      order.deliveryAddress!,
                                                      style: AppTextStyle.body(
                                                          context,
                                                          color: AppColor
                                                              .textSecondary(
                                                                  context),
                                                          fontSize: 13),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (order.paymentMethod != null) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.payment_outlined,
                                                      size: 14,
                                                      color: AppColor.textSecondary(context)),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Paid via: ${order.paymentMethod}',
                                                    style: AppTextStyle.body(context,
                                                        color: AppColor.textSecondary(context),
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            const SizedBox(height: 10),
                                            // Items
                                            if (order.items.isNotEmpty)
                                              ...order.items.map((item) =>
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                            Icons
                                                                .fastfood_outlined,
                                                            size: 14,
                                                            color: AppColor
                                                                .textSecondary(
                                                                    context)),
                                                        const SizedBox(
                                                            width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            '${item.food?.name ?? 'Food #${item.foodId}'} x${item.quantity}',
                                                            style: AppTextStyle.body(
                                                                context,
                                                                color: AppColor
                                                                    .textBody(
                                                                        context),
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                        Text(
                                                          '\$${item.price.toStringAsFixed(2)}',
                                                          style: AppTextStyle.accent(
                                                              context,
                                                              color: AppColor
                                                                  .textAccent(
                                                                      context),
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            const Divider(),
                                            // Total + Date
                                            Row(
                                              children: [
                                                Text(
                                                  '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                                                  style: AppTextStyle.body(
                                                      context,
                                                      color: AppColor
                                                          .textSecondary(
                                                              context),
                                                      fontSize: 13),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                                                  style: AppTextStyle.bodyBold(
                                                      context,
                                                      color: AppColor.textTitle(
                                                          context),
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
