import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/restaurant/widget/order_action_bottom_sheet.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_order_card.dart';
import 'package:flutter/material.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<RestaurantOrder> _allOrders = [
    RestaurantOrder(
      orderId: '3',
      orderNumber: '0220',
      time: '04:50 PM',
      customerName: 'Alice Nguyen',
      customerPhone: '+1 555 123 456',
      address: '15 River Road, Mumbai',
      items: [RestaurantOrderItem(name: 'Dal Tadka', quantity: 2, price: 250)],
      totalBill: 250,
      paymentMode: 'Online',
      status: RestaurantOrderStatus.completed,
    ),
    RestaurantOrder(
      orderId: '4',
      orderNumber: '0219',
      time: '03:30 PM',
      customerName: 'John Smith',
      address: '8 Park Lane, Mumbai',
      items: [RestaurantOrderItem(name: 'Veg Biryani', quantity: 1, price: 200)],
      totalBill: 200,
      paymentMode: 'Cash',
      status: RestaurantOrderStatus.cancelled,
    ),
    RestaurantOrder(
      orderId: '5',
      orderNumber: '0218',
      time: '02:15 PM',
      customerName: 'Priya Sharma',
      address: '22 Hill View, Mumbai',
      items: [
        RestaurantOrderItem(name: 'Butter Chicken', quantity: 1, price: 220),
        RestaurantOrderItem(name: 'Garlic Naan', quantity: 3, price: 60),
      ],
      totalBill: 280,
      paymentMode: 'Online',
      status: RestaurantOrderStatus.completed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<RestaurantOrder> _filterByStatus(RestaurantOrderStatus status) =>
      _allOrders.where((o) => o.status == status).toList();

  void _openOrderDetail(RestaurantOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderActionBottomSheet(order: order),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList(_allOrders),
          _buildOrderList(_filterByStatus(RestaurantOrderStatus.completed)),
          _buildOrderList(_filterByStatus(RestaurantOrderStatus.cancelled)),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<RestaurantOrder> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 60, color: AppColor.textSecondary(context).withOpacity(0.3)),
            const SizedBox(height: 12),
            Text('No orders found', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: orders.length,
      itemBuilder: (_, index) {
        final order = orders[index];
        return RestaurantOrderCard(
          order: order,
          onMoreTap: () => _openOrderDetail(order),
        );
      },
    );
  }
}
