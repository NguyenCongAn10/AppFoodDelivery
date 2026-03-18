import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

class RestaurantSalesScreen extends StatelessWidget {
  const RestaurantSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final salesData = [
      {'day': 'Mon', 'amount': 1200.0},
      {'day': 'Tue', 'amount': 950.0},
      {'day': 'Wed', 'amount': 1480.0},
      {'day': 'Thu', 'amount': 800.0},
      {'day': 'Fri', 'amount': 1750.0},
      {'day': 'Sat', 'amount': 2100.0},
      {'day': 'Sun', 'amount': 1600.0},
    ];
    final maxAmount = salesData.map((e) => e['amount'] as double).reduce((a, b) => a > b ? a : b);
    final totalWeekly = salesData.fold(0.0, (sum, e) => sum + (e['amount'] as double));

    return Scaffold(
      backgroundColor: AppColor.inputFill(context),
      appBar: AppBar(
        backgroundColor: AppColor.container(context),
        title: Text('Sales', style: AppTextStyle.bodyBold(context, fontSize: 18)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Revenue Overview Cards
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'Today', 'Rs. 1,750', Icons.today_outlined, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'This Week', 'Rs. ${totalWeekly.toStringAsFixed(0)}', Icons.calendar_today_outlined, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(context, 'This Month', 'Rs. 28,400', Icons.bar_chart_outlined, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(context, 'Avg. Order', 'Rs. 185', Icons.receipt_outlined, Colors.purple)),
            ],
          ),
          const SizedBox(height: 20),
          // Weekly Bar Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.container(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Revenue', style: AppTextStyle.bodyBold(context, fontSize: 15)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 140,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: salesData.map((data) {
                      final ratio = (data['amount'] as double) / maxAmount;
                      return _buildBar(context, data['day'] as String, data['amount'] as double, ratio);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Top Items
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.container(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Selling Items', style: AppTextStyle.bodyBold(context, fontSize: 15)),
                const SizedBox(height: 16),
                ...[
                  ('Paneer Masala', '48 orders', 0.85),
                  ('Veg Thali', '36 orders', 0.65),
                  ('Dal Tadka', '28 orders', 0.50),
                  ('Roti', '60 orders', 1.0),
                ].map((item) => _buildTopItem(context, item.$1, item.$2, item.$3)).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
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
        Text('${(amount / 1000).toStringAsFixed(1)}k', style: AppTextStyle.body(context, fontSize: 10, color: AppColor.textSecondary(context))),
        const SizedBox(height: 4),
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          width: 28,
          height: 110 * ratio,
          decoration: BoxDecoration(
            color: AppColor.primary(context),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 6),
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
