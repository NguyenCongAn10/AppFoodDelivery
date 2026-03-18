import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/features/restaurant/widget/restaurant_order_card.dart';
import 'package:flutter/material.dart';

// Reuse RestaurantOrder for delivery orders (same data model works for shipper view)
class ShipperHomeScreen extends StatelessWidget {
  const ShipperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableOrders = [
      RestaurantOrder(
        orderId: '10',
        orderNumber: '0230',
        time: '06:00 PM',
        customerName: 'Michael Chen',
        customerPhone: '+1 444 555 666',
        address: '99 Blossom St, Mumbai',
        items: [RestaurantOrderItem(name: 'Butter Chicken', quantity: 2, price: 440)],
        totalBill: 440,
        paymentMode: 'Online',
        status: RestaurantOrderStatus.ready,
      ),
      RestaurantOrder(
        orderId: '11',
        orderNumber: '0229',
        time: '05:45 PM',
        customerName: 'Sarah Johnson',
        customerPhone: '+1 222 333 444',
        address: '5 Elm Drive, Mumbai',
        items: [
          RestaurantOrderItem(name: 'Veg Biryani', quantity: 1, price: 200),
          RestaurantOrderItem(name: 'Raita', quantity: 1, price: 30),
        ],
        totalBill: 230,
        paymentMode: 'Cash',
        status: RestaurantOrderStatus.ready,
      ),
    ];

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
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          )
        ],
      ),
      body: availableOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delivery_dining_outlined, size: 70, color: AppColor.textSecondary(context).withOpacity(0.3)),
                  const SizedBox(height: 14),
                  Text('No deliveries available', style: AppTextStyle.body(context, color: AppColor.textSecondary(context))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: availableOrders.length,
              itemBuilder: (_, index) {
                final order = availableOrders[index];
                return _DeliveryCard(order: order);
              },
            ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final RestaurantOrder order;
  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.container(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '#${order.orderNumber}  •  ${order.time}',
                style: AppTextStyle.bodyBold(context, color: AppColor.primary(context), fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Ready', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.red),
              const SizedBox(width: 6),
              Expanded(
                child: Text(order.address, style: AppTextStyle.body(context, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(order.customerName, style: AppTextStyle.body(context, fontSize: 13)),
              const Spacer(),
              Text('Rs. ${order.totalBill.toStringAsFixed(0)}', style: AppTextStyle.bodyBold(context, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                elevation: 0,
              ),
              child: const Text('ACCEPT DELIVERY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
