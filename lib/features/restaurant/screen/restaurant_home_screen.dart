import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/restaurant_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:delivery_apps/features/restaurant/widget/order_action_bottom_sheet.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_order_card.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RestaurantHomeScreen extends StatefulWidget {
  const RestaurantHomeScreen({super.key});

  @override
  State<RestaurantHomeScreen> createState() => _RestaurantHomeScreenState();
}

class _RestaurantHomeScreenState extends State<RestaurantHomeScreen> {
  final BackendService _backendService = BackendService();
  bool _isLoading = true;
  RestaurantModel? _restaurant;
  List<RestaurantOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final restaurant = await _backendService.getMyRestaurant();
      final orderModels = await _backendService.getRestaurantOrders();
      
      if (mounted) {
        setState(() {
          _restaurant = restaurant;
          _orders = orderModels.map((m) => _mapToRestaurantOrder(m)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching restaurant data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  RestaurantOrder _mapToRestaurantOrder(OrderModel model) {
    return RestaurantOrder(
      orderId: model.id.toString(),
      orderNumber: model.id.toString().padLeft(4, '0'),
      time: DateFormat('hh:mm a').format(model.createdAt),
      customerName: model.user?.name ?? 'Guest User',
      customerPhone: model.user?.phone,
      address: model.deliveryAddress ?? 'No Address',
      items: model.items.map((i) => RestaurantOrderItem(
        name: i.food?.name ?? 'Unknown Item',
        quantity: i.quantity,
        price: i.price,
      )).toList(),
      totalBill: model.totalPrice,
      paymentMode: model.paymentMethod ?? 'Unknown',
      status: _mapStatus(model.status),
    );
  }

  RestaurantOrderStatus _mapStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING: return RestaurantOrderStatus.pending;
      case OrderStatus.CONFIRMED: return RestaurantOrderStatus.accepted;
      case OrderStatus.DELIVERING: return RestaurantOrderStatus.ready;
      case OrderStatus.COMPLETED: return RestaurantOrderStatus.completed;
      case OrderStatus.CANCELLED: return RestaurantOrderStatus.cancelled;
    }
  }

  OrderStatus _mapToBackendStatus(RestaurantOrderStatus status) {
    switch (status) {
      case RestaurantOrderStatus.pending: return OrderStatus.PENDING;
      case RestaurantOrderStatus.accepted: 
      case RestaurantOrderStatus.preparing:
        return OrderStatus.CONFIRMED;
      case RestaurantOrderStatus.ready: return OrderStatus.DELIVERING;
      case RestaurantOrderStatus.completed: return OrderStatus.COMPLETED;
      case RestaurantOrderStatus.cancelled: return OrderStatus.CANCELLED;
    }
  }

  int get _totalOrders => _orders.length;
  int get _completedOrders => _orders.where((o) => o.status == RestaurantOrderStatus.completed).length;
  int get _cancelledOrders => _orders.where((o) => o.status == RestaurantOrderStatus.cancelled).length;

  List<RestaurantOrder> get _currentOrders => _orders
      .where((o) =>
          o.status == RestaurantOrderStatus.pending ||
          o.status == RestaurantOrderStatus.accepted ||
          o.status == RestaurantOrderStatus.preparing ||
          o.status == RestaurantOrderStatus.ready)
      .toList();

  void _openOrderDetail(RestaurantOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: OrderActionBottomSheet(
          order: order,
          onAccept: () => _updateOrderStatus(order, RestaurantOrderStatus.accepted),
          onReject: () => _updateOrderStatus(order, RestaurantOrderStatus.cancelled),
          onReady: () => _updateOrderStatus(order, RestaurantOrderStatus.ready),
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(RestaurantOrder order, RestaurantOrderStatus newStatus) async {
    try {
      final backendStatus = _mapToBackendStatus(newStatus);
      String action = 'confirm'; // default
      if (backendStatus == OrderStatus.CANCELLED) action = 'cancel';
      if (backendStatus == OrderStatus.DELIVERING) action = 'ready'; // for backend ready means delivering if we map like this

      await _backendService.updateOrderStatus(int.parse(order.orderId), action);
      
      setState(() {
        order.status = newStatus;
        // If it was cancelled or completed, it will be filtered out of current orders
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${order.orderNumber} updated to ${newStatus.name}')),
        );
      }
    } catch (e) {
      debugPrint('Error updating order status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order status')),
        );
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool val) async {
    try {
      await _backendService.updateRestaurantStatus(val);
      setState(() {
        _restaurant = RestaurantModel(
          id: _restaurant!.id,
          userUid: _restaurant!.userUid,
          restaurantName: _restaurant!.restaurantName,
          address: _restaurant!.address,
          latitude: _restaurant!.latitude,
          longitude: _restaurant!.longitude,
          rating: _restaurant!.rating,
          ratingCount: _restaurant!.ratingCount,
          isOpen: val,
          createdAt: _restaurant!.createdAt,
          foods: _restaurant!.foods,
        );
      });
    } catch (e) {
      debugPrint('Error toggling online status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      body: RefreshIndicator(
        color: AppColor.primary(context),
        onRefresh: _fetchData,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 90,
              floating: true,
              snap: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              backgroundColor: AppColor.primary(context),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CURRENT LOCATION',
                                style: AppTextStyle.body(context, fontSize: 11, color: Colors.white70),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _restaurant?.address ?? 'Loading...',
                                      style: AppTextStyle.bodyBold(context, fontSize: 13, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Online Toggle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Switch(
                                value: _restaurant?.isOpen ?? false,
                                onChanged: _toggleOnlineStatus,
                                activeColor: Colors.white,
                                activeTrackColor: Colors.green,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (_restaurant?.isOpen ?? false) ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color: (_restaurant?.isOpen ?? false) ? Colors.greenAccent : Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.white, size: 20),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              // Summary Card
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("TODAY'S SUMMARY", style: AppTextStyle.bodyBold(context, fontSize: 13, color: AppColor.textSecondary(context))),
                    ),
                    const SizedBox(height: 8),
                    RestaurantSummaryCard(
                      restaurantName: _restaurant?.restaurantName ?? 'Loading...',
                      restaurantAddress: (_restaurant?.address ?? '').split(',').first,
                      totalOrders: _totalOrders,
                      completedOrders: _completedOrders,
                      cancelledOrders: _cancelledOrders,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'CURRENT ORDERS',
                        style: AppTextStyle.bodyBold(context, fontSize: 13, color: AppColor.textSecondary(context)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // Current Orders List
              if (_currentOrders.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 60, color: AppColor.textSecondary(context).withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text('No active orders', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final order = _currentOrders[index];
                      return RestaurantOrderCard(
                        order: order,
                        onMoreTap: () => _openOrderDetail(order),
                        onAccept: () => _updateOrderStatus(order, RestaurantOrderStatus.accepted),
                        onReject: () => _updateOrderStatus(order, RestaurantOrderStatus.cancelled),
                        onReady: () => _updateOrderStatus(order, RestaurantOrderStatus.ready),
                      );
                    },
                    childCount: _currentOrders.length,
                  ),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
