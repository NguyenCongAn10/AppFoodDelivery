import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/services/backend_service.dart';
import 'package:flutter/material.dart';

class RestaurantSalesScreen extends StatefulWidget {
  const RestaurantSalesScreen({super.key});

  @override
  State<RestaurantSalesScreen> createState() => _RestaurantSalesScreenState();
}

class _RestaurantSalesScreenState extends State<RestaurantSalesScreen> {
  bool _isLoading = true;
  double _todayRevenue = 0;
  double _weeklyRevenue = 0;
  double _monthlyRevenue = 0;
  double _avgOrderValue = 0;
  List<Map<String, dynamic>> _dailyData = [];
  List<Map<String, dynamic>> _topItems = [];

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  Future<void> _fetchSalesData() async {
    setState(() => _isLoading = true);
    try {
      final orders = await BackendService().getRestaurantOrders();
      final completedOrders =
          orders.where((o) => o.status == OrderStatus.COMPLETED).toList();

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Calculations
      _todayRevenue = completedOrders
          .where((o) => o.createdAt.isAfter(today))
          .fold(0.0, (sum, o) => sum + o.totalPrice);

      _weeklyRevenue = completedOrders
          .where((o) => o.createdAt.isAfter(startOfWeek))
          .fold(0.0, (sum, o) => sum + o.totalPrice);

      _monthlyRevenue = completedOrders
          .where((o) => o.createdAt.isAfter(startOfMonth))
          .fold(0.0, (sum, o) => sum + o.totalPrice);

      final monthlyCompletedOrders = completedOrders
          .where((o) => o.createdAt.isAfter(startOfMonth))
          .toList();
      _avgOrderValue = monthlyCompletedOrders.isEmpty
          ? 0
          : _monthlyRevenue / monthlyCompletedOrders.length;
      if (_avgOrderValue.isNaN) _avgOrderValue = 0;

      // Weekly Chart Data
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      _dailyData = weekdays.asMap().entries.map((entry) {
        final dayIndex = entry.key + 1; // 1 = Mon, 7 = Sun
        final dayOrders = completedOrders.where((o) {
          return o.createdAt.isAfter(startOfWeek) &&
              o.createdAt.weekday == dayIndex;
        });
        return {
          'day': entry.value,
          'amount': dayOrders.fold(0.0, (sum, o) => sum + o.totalPrice),
        };
      }).toList();

      // Top Items
      final itemCounts = <int, Map<String, dynamic>>{};
      for (var border in completedOrders) {
        for (var item in border.items) {
          final foodId = item.foodId;
          final foodName = item.food?.name ?? "Unknown Item";
          if (!itemCounts.containsKey(foodId)) {
            itemCounts[foodId] = {'name': foodName, 'count': 0};
          }
          itemCounts[foodId]!['count'] += item.quantity;
        }
      }

      final sortedItems = itemCounts.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      _topItems = sortedItems.take(4).toList();
    } catch (e) {
      debugPrint("Error fetching sales data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColor.inputFill(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final maxAmount = _dailyData.isEmpty
        ? 1.0
        : _dailyData
            .map((e) => e['amount'] as double)
            .reduce((a, b) => a > b ? a : b);
    final displayMax = maxAmount == 0 ? 1.0 : maxAmount;

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text('Sales Analytics',
            style: AppTextStyle.bodyBold(context, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _fetchSalesData, icon: const Icon(Icons.refresh))
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSalesData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Today',
                        '\$ ${_todayRevenue.toStringAsFixed(0)}',
                        Icons.today_outlined,
                        Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        context,
                        'This Week',
                        '\$ ${_weeklyRevenue.toStringAsFixed(0)}',
                        Icons.calendar_today_outlined,
                        Colors.green)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'This Month',
                        '\$ ${_monthlyRevenue.toStringAsFixed(0)}',
                        Icons.bar_chart_outlined,
                        Colors.orange)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Avg. Order',
                        '\$ ${_avgOrderValue.toStringAsFixed(0)}',
                        Icons.receipt_outlined,
                        Colors.purple)),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Revenue',
                      style: AppTextStyle.bodyBold(context, fontSize: 15)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dailyData.map((data) {
                        final ratio = (data['amount'] as double) / displayMax;
                        return _buildBar(context, data['day'] as String,
                            data['amount'] as double, ratio);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.container(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Selling Items',
                      style: AppTextStyle.bodyBold(context, fontSize: 15)),
                  const SizedBox(height: 16),
                  if (_topItems.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                          child: Text("No data available",
                              style: AppTextStyle.body(context,
                                  color: AppColor.textSecondary(context)))),
                    )
                  else
                    ..._topItems.asMap().entries.map((entry) {
                      final item = entry.value;
                      final maxCount = _topItems[0]['count'] as int;
                      final ratio = maxCount == 0
                          ? 0.0
                          : (item['count'] as int) / maxCount;
                      return _buildTopItem(context, item['name'],
                          '${item['count']} orders', ratio);
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyle.bodyBold(context, fontSize: 16)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String day, double amount, double ratio) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
            amount >= 1000
                ? '${(amount / 1000).toStringAsFixed(1)}k'
                : amount.toStringAsFixed(0),
            style: AppTextStyle.body(context,
                fontSize: 10, color: AppColor.textSecondary(context))),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 28,
          height: 100 * ratio,
          decoration: BoxDecoration(
            color: AppColor.primary(context),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: AppTextStyle.body(context, fontSize: 11, color: AppColor.textSecondary(context))),
      ],
    );
  }

  Widget _buildTopItem(BuildContext context, String name, String orders, double ratio) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyle.bodyBold(context, fontSize: 13)),
              Text(orders, style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColor.inputFill(context),
              valueColor: AlwaysStoppedAnimation(AppColor.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
}
