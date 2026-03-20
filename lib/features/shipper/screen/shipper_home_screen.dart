import 'package:delivery_apps/core/common/app_text_style.dart';
import 'package:delivery_apps/core/common/color_extension.dart';
import 'package:delivery_apps/core/models/food_model.dart';
import 'package:delivery_apps/core/models/order_model.dart';
import 'package:delivery_apps/core/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Reuse RestaurantOrder for delivery orders (same data model works for shipper view)
class ShipperHomeScreen extends StatelessWidget {
  const ShipperHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final availableOrders = [
      OrderModel(
        id: 10,
        userUid: 'u1',
        restaurantId: 1,
        status: OrderStatus.DELIVERING, // Ready to be picked up
        totalPrice: 440,
        deliveryAddress: '99 Blossom St, Mumbai',
        paymentMethod: 'Online',
        createdAt: DateTime.now().subtract(const Duration(minutes: 60)),
        user: UserModel(
          id: 1,
          uid: 'u1',
          name: 'Michael Chen',
          email: 'm@c.com',
          phone: '+1 444 555 666',
          role: UserRole.USER,
          createdAt: DateTime.now(),
        ),
        items: [
          OrderItemModel(
            id: 1,
            orderId: 10,
            foodId: 1,
            quantity: 2,
            price: 220,
            food: FoodModel(
              id: 1,
              restaurantId: 1,
              categoryId: 1,
              name: 'Butter Chicken',
              description: '',
              price: 220,
              isAvailable: true,
              createdAt: DateTime.now(),
            ),
          )
        ],
      ),
      OrderModel(
        id: 11,
        userUid: 'u2',
        restaurantId: 1,
        status: OrderStatus.DELIVERING,
        totalPrice: 230,
        deliveryAddress: '5 Elm Drive, Mumbai',
        paymentMethod: 'Cash',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        user: UserModel(
          id: 2,
          uid: 'u2',
          name: 'Sarah Johnson',
          email: 's@j.com',
          phone: '+1 222 333 444',
          role: UserRole.USER,
          createdAt: DateTime.now(),
        ),
        items: [
          OrderItemModel(
            id: 2,
            orderId: 11,
            foodId: 2,
            quantity: 1,
            price: 200,
            food: FoodModel(
              id: 2,
              restaurantId: 1,
              categoryId: 1,
              name: 'Veg Biryani',
              description: '',
              price: 200,
              isAvailable: true,
              createdAt: DateTime.now(),
            ),
          ),
          OrderItemModel(
            id: 3,
            orderId: 11,
            foodId: 3,
            quantity: 1,
            price: 30,
            food: FoodModel(
              id: 3,
              restaurantId: 1,
              categoryId: 1,
              name: 'Raita',
              description: '',
              price: 30,
              isAvailable: true,
              createdAt: DateTime.now(),
            ),
          ),
        ],
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
                  Icon(Icons.delivery_dining_outlined, size: 70, color: AppColor.textSecondary(context).withValues(alpha: 0.3)),
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
  final OrderModel order;
  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(order.createdAt);
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
                child: Text(order.deliveryAddress ?? 'No Address', style: AppTextStyle.body(context, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.blue),
              const SizedBox(width: 6),
              Text(order.user?.name ?? 'Guest User', style: AppTextStyle.body(context, fontSize: 13)),
              const Spacer(),
              Text('Rs. ${order.totalPrice.toStringAsFixed(0)}', style: AppTextStyle.bodyBold(context, fontSize: 14)),
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
