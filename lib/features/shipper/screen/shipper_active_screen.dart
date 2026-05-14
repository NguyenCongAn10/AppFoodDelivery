import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/shipper/screen/shipper_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShipperActiveScreen extends StatefulWidget {
  const ShipperActiveScreen({super.key});

  @override
  State<ShipperActiveScreen> createState() => _ShipperActiveScreenState();
}

class _ShipperActiveScreenState extends State<ShipperActiveScreen> {
  bool _isLoading = true;
  String? _error;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveOrders();
  }

  Future<void> _fetchActiveOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allAssigned = await BackendService().getAssignedOrders();
      
      if (mounted) {
        setState(() {
          _orders = allAssigned.where((o) =>
            o.status == OrderStatus.PENDING ||
            o.status == OrderStatus.CONFIRMED ||
            o.status == OrderStatus.DELIVERING
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeOrder(int orderId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await BackendService().updateOrderStatus(orderId, 'complete');
      
      if (mounted) {
        Navigator.pop(context); // Tắt loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order completed!'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchActiveOrders(); // Load lại danh sách
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.primary(context),
        title: Text('Active Deliveries', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchActiveOrders,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchActiveOrders,
        color: AppColor.primary(context),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchActiveOrders,
                  child: const Text('Retry'),
                )
              ],
            ),
          )
        ],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_motorsports_outlined, size: 70, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
                const SizedBox(height: 14),
                Text('No active deliveries', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
              ],
            ),
          )
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _orders.length,
      itemBuilder: (_, index) {
        final order = _orders[index];
        return _ActiveDeliveryCard(
          order: order,
          onComplete: () => _completeOrder(order.id),
          onNavigate: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShipperMapScreen(order: order),
              ),
            );
            if (mounted) {
               _fetchActiveOrders();
            }
          },
        );
      },
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onComplete;
  final VoidCallback onNavigate;
  
  const _ActiveDeliveryCard({
    required this.order, 
    required this.onComplete,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(order.createdAt);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.primary(context).withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColor.primary(context).withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id.toString().padLeft(4, '0')}  •  $timeStr',
                style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
                    ),
                    const SizedBox(width: 6),
                    Text(order.status == OrderStatus.CONFIRMED ? 'Picking up' : 'Delivering', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Restaurant
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.storefront, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.restaurant?.restaurantName ?? 'Restaurant', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                    Text(order.restaurant?.address ?? 'Restaurant address', style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
            child: Container(
              height: 20, 
              width: 2, 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(2)
              ),
            ),
          ),
          
          // Customer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.user?.name ?? 'Customer', style: AppTextStyle.bodyBold(context, fontSize: 14)),
                    Text(order.user?.phone ?? 'No Phone', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.primary(context))),
                    Text(order.deliveryAddress ?? 'Delivery address', style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                 icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () async {
                  final phone = order.user?.phone;
                  if (phone == null || phone.isEmpty) return;
                  final uri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                 },
              )
            ],
          ),
          
          const Divider(height: 24),
          
          Row(
            children: [
              Text('${order.items.length} items', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
              const Spacer(),
              Text('Collect: ', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
              Text(
                order.paymentMethod?.toLowerCase() == 'cash' 
                      ? '${order.totalPrice.toStringAsFixed(0)} \$'
                  : 'Paid', 
                style: AppTextStyle.bodyBold(context, fontSize: 16, color: order.paymentMethod?.toLowerCase() == 'cash' ? Colors.red : Colors.green)
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: onNavigate,
                    icon: Icon(Icons.map, color: AppColor.primary(context)),
                    label: Text('MAP', style: TextStyle(color: AppColor.primary(context), fontWeight: FontWeight.bold, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColor.primary(context)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      elevation: 0,
                    ),
                    child: const Text('COMPLETE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
