import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShipperHistoryScreen extends StatefulWidget {
  const ShipperHistoryScreen({super.key});

  @override
  State<ShipperHistoryScreen> createState() => _ShipperHistoryScreenState();
}

class _ShipperHistoryScreenState extends State<ShipperHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoryOrders();
  }

  Future<void> _fetchHistoryOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final allAssigned = await BackendService().getAssignedOrders();
      if (mounted) {
        setState(() {
          // Lọc ra các đơn hàng đã hoàn thành hoặc hủy
          _orders = allAssigned.where((o) => 
            o.status == OrderStatus.COMPLETED || o.status == OrderStatus.CANCELLED
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        title: Text('Delivery History', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        backgroundColor: AppColor.primary(context),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchHistoryOrders,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistoryOrders,
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
                  onPressed: _fetchHistoryOrders,
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
                Icon(Icons.history, size: 70, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
                const SizedBox(height: 14),
                Text('No delivery history', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
              ],
            ),
          )
        ],
      );
    }

    // Tính tổng thu nhập nháp (tổng tiền các đơn, thực tế có thể chia % sau)
    final totalEarned = _orders.where((o) => o.status == OrderStatus.COMPLETED)
                               .fold(0.0, (sum, o) => sum + o.totalPrice);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColor.primary(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatBox('Total Orders', '${_orders.length}'),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatBox('Completed', '${_orders.where((o) => o.status == OrderStatus.COMPLETED).length}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: _orders.length,
            itemBuilder: (_, index) {
              final order = _orders[index];
              return _HistoryCard(order: order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyle.bodyBold(context, fontSize: 22, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OrderModel order;
  const _HistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final timeStr = dateFormat.format(order.createdAt);
    final isCompleted = order.status == OrderStatus.COMPLETED;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.id.toString().padLeft(4, '0')}',
                style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 14),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Completed' : 'Cancelled', 
                  style: TextStyle(
                    color: isCompleted ? Colors.green : Colors.red, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  )
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Icon(Icons.storefront, size: 16, color: AppColor.textSecondary(context)),
               const SizedBox(width: 8),
               Expanded(child: Text(order.restaurant?.restaurantName ?? 'Restaurant', style: AppTextStyle.body(context, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Icon(Icons.location_on, size: 16, color: AppColor.textSecondary(context)),
               const SizedBox(width: 8),
               Expanded(child: Text(order.deliveryAddress ?? 'Address', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context)))),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              Text(timeStr, style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
              const Spacer(),
              Text('${order.totalPrice.toStringAsFixed(0)}đ', style: AppTextStyle.bodyBold(context, fontSize: 15, color: isCompleted ? Colors.green : Colors.red)),
            ],
          )
        ],
      ),
    );
  }
}
