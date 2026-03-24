import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/restaurant/widget/order_action_bottom_sheet.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_order_card.dart';
import 'package:flutter/material.dart';

import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BackendService _backendService = BackendService();

  List<OrderModel> _allOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _backendService.getRestaurantOrders();
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load orders')),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(OrderModel order, String action) async {
    try {
      // Show loading overlay or simply await
      await _backendService.updateOrderStatus(order.id, action);
      // Refresh the list
      _fetchOrders();
    } catch (e) {
      debugPrint('Error updating order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order')),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterByStatus(OrderStatus status) =>
      _allOrders.where((o) => o.status == status).toList();

  void _openOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderActionBottomSheet(
        order: order,
        onAccept: () => _updateOrderStatus(order, 'confirm'),
        onReject: () => _updateOrderStatus(order, 'cancel'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text('Order History', style: AppTextStyle.bodyBold(context, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColor.primary(context),
          labelColor: AppColor.primary(context),
          unselectedLabelColor: AppColor.textSecondary(context),
          labelStyle: AppTextStyle.bodyBold(context, fontSize: 13),
          unselectedLabelStyle: AppTextStyle.body(context, fontSize: 13),
          tabs: const [Tab(text: 'All'), Tab(text: 'Completed'), Tab(text: 'Cancelled')],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(_allOrders),
              _buildOrderList(_filterByStatus(OrderStatus.COMPLETED)),
              _buildOrderList(_filterByStatus(OrderStatus.CANCELLED)),
            ],
          ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchOrders,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 60, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                Text('No orders found', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
              ],
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (_, index) {
          final order = orders[index];
          return RestaurantOrderCard(
            order: order,
            onMoreTap: () => _openOrderDetail(order),
            onAccept: () => _updateOrderStatus(order, 'confirm'),
            onReject: () => _updateOrderStatus(order, 'cancel'),
            onReady: () => _updateOrderStatus(order, 'ready'),
          );
        },
      ),
    );
  }
}
