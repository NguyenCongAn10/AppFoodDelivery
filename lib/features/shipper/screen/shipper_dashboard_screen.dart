import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShipperDashboardScreen extends StatefulWidget {
  const ShipperDashboardScreen({super.key});

  @override
  State<ShipperDashboardScreen> createState() => _ShipperDashboardScreenState();
}

class _ShipperDashboardScreenState extends State<ShipperDashboardScreen> {
  bool _isLoading = true;
  String? _error;
  double _totalEarnings = 0;
  int _totalDeliveries = 0;
  List<OrderModel> _recentDeliveries = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await BackendService().getShipperDashboard();
      if (mounted) {
        setState(() {
          _totalEarnings = (data['total_earnings'] as num).toDouble();
          _totalDeliveries = data['total_deliveries'] as int;
          
          final List list = data['recent_deliveries'];
          _recentDeliveries = list.map((e) => OrderModel.fromJson(e)).toList();
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
        backgroundColor: AppColor.primary(context),
        title: Text('Earnings Dashboard', style: AppTextStyle.bodyBold(context, fontSize: 18, color: Colors.white)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
             icon: const Icon(Icons.refresh, color: Colors.white),
             onPressed: _fetchDashboard,
          )
        ],
      ),
      body: RefreshIndicator(
        color: AppColor.primary(context),
        onRefresh: _fetchDashboard,
        child: _buildBody(),
      )
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
                  child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _fetchDashboard, child: const Text('Retry'))
              ],
            ),
          )
        ]
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColor.primary(context), AppColor.primary(context).withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: AppColor.primary(context).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 40),
                const SizedBox(height: 12),
                const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalEarnings.toStringAsFixed(2)}', 
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delivery_dining, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text('$_totalDeliveries Deliveries Completed', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          Text('Recent Deliveries', style: AppTextStyle.bodyBold(context, fontSize: 18)),
          const SizedBox(height: 16),
          
          if (_recentDeliveries.isEmpty)
             Center(
               child: Padding(
                 padding: const EdgeInsets.only(top: 40),
                 child: Text('No completed deliveries yet', style: TextStyle(color: AppColor.textSecondary(context))),
               )
             )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentDeliveries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = _recentDeliveries[index];
                final timeStr = DateFormat('MMM dd, HH:mm').format(order.createdAt);
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.container(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order #${order.id}', style: AppTextStyle.bodyBold(context, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text(timeStr, style: TextStyle(color: AppColor.textSecondary(context), fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                         '+\$${order.deliveryFee?.toStringAsFixed(2) ?? "0.00"}',
                         style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)
                      )
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }
}
