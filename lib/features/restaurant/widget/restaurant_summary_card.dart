import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:flutter/material.dart';

class RestaurantSummaryCard extends StatelessWidget {
  final String restaurantName;
  final String restaurantAddress;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;

  const RestaurantSummaryCard({
    super.key,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColor.primary(context).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.storefront_rounded, color: AppColor.primary(context), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurantName, style: AppTextStyle.bodyBold(context, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      restaurantAddress,
                      style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColor.primary(context).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildStatItem(context, totalOrders.toString(), 'Orders'),
                _buildDivider(context),
                _buildStatItem(context, completedOrders.toString(), 'Completed'),
                _buildDivider(context),
                _buildStatItem(context, cancelledOrders.toString(), 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyle.bodyBold(context, fontSize: 22, color: AppColor.primary(context)),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyle.body(context, fontSize: 12, color: AppColor.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColor.primary(context).withOpacity(0.2),
    );
  }
}
