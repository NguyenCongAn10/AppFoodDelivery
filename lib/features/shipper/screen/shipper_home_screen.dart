import 'dart:async';

import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/providers/order_realtime_provider.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ShipperHomeScreen extends StatefulWidget {
  final VoidCallback? onAcceptOrder;
  const ShipperHomeScreen({super.key, this.onAcceptOrder});

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen> {
  bool _isLoading = true;
  bool _isFetching = false;
  String? _error;
  List<OrderModel> _orders = [];
  Position? _currentPosition;
  Map<String, dynamic>? _lastPayload;
  late OrderRealtimeProvider _realtimeProvider;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _realtimeProvider = context.read<OrderRealtimeProvider>();
    _realtimeProvider.subscribe();
    // Fallback polling in case Supabase realtime events are missed
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _fetchOrders(showLoading: false);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeProvider.unsubscribe();
    super.dispose();
  }

  Future<void> _fetchOrders({bool showLoading = true}) async {
    if (!mounted || _isFetching) return;
    _isFetching = true;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Kiểm tra và xin quyền location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Lấy vị trí hiện tại
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Gọi API lấy đơn hàng trong vòng 15km
      final orders = await BackendService().getAvailableOrders(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      if (mounted) {
        setState(() {
          _orders = orders;
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
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _acceptOrder(int orderId) async {
    try {
      // Hiện loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await BackendService().acceptOrder(orderId);
      
      if (mounted) {
        Navigator.pop(context); // Tắt loading dialog
        _fetchOrders(); // Refresh the list so it doesn't show up again
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Chuyển sang tab Active (callback)
        widget.onAcceptOrder?.call();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting order: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auto-refresh when new order is available (realtime INSERT)
    final payload = context.select<OrderRealtimeProvider, Map<String, dynamic>?>(
      (p) => p.latestPayload,
    );
    if (payload != null && payload != _lastPayload) {
      _lastPayload = payload;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchOrders(showLoading: false);
      });
    }

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.primary(context),
        title: Text('Available Deliveries', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
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
                  onPressed: _fetchOrders,
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
                Icon(Icons.location_off_outlined, size: 70, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
                const SizedBox(height: 14),
                Text('No available deliveries around you', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
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
        return _DeliveryCard(
          order: order,
          onAccept: () => _acceptOrder(order.id),
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onAccept;
  
  const _DeliveryCard({required this.order, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(order.createdAt);
    
    // Tìm distance_km từ order JSON raw data (nếu có bổ sung parse json sau)
    // Hoặc tạm thời dùng 1 thông số mặc định nếu ko map đc
    // Trong BE chúng ta send về order có field 'distance_km'
    
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
                '#${order.id.toString().padLeft(4, '0')}  •  $timeStr',
                style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('New', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
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
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(height: 15, width: 2, color: Colors.grey.shade300),
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
                    Text(order.deliveryAddress ?? 'Delivery address', style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),
          
          Row(
            children: [
              Text('${order.items.length} items', style: AppTextStyle.body(context, fontSize: 13, color: AppColor.textSecondary(context))),
              const Spacer(),
              Text('Total: ', style: AppTextStyle.body(context, fontSize: 13)),
              Text('${order.totalPrice.toStringAsFixed(0)} \$',
                  style: AppTextStyle.bodyBold(context, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                elevation: 0,
              ),
              child: const Text('ACCEPT ORDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
