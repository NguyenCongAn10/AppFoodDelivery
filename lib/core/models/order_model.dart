import 'food_model.dart';
import 'user_model.dart';
import 'restaurant_model.dart';
import 'shipper_model.dart';

enum OrderStatus {
  PENDING,
  CONFIRMED,
  DELIVERING,
  COMPLETED,
  CANCELLED,
}

class OrderModel {
  final int id;
  final int userId;
  final int restaurantId;
  final int? shipperId;
  final OrderStatus status;
  final double totalPrice;
  final DateTime createdAt;
  final UserModel? user;
  final RestaurantModel? restaurant;
  final ShipperModel? shipper;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.shipperId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.user,
    this.restaurant,
    this.shipper,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      restaurantId: json['restaurant_id'],
      shipperId: json['shipper_id'],
      status: OrderStatus.values.firstWhere((e) => e.toString().split('.').last == json['status'], orElse: () => OrderStatus.PENDING),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
      restaurant: json['restaurants'] != null ? RestaurantModel.fromJson(json['restaurants']) : null,
      shipper: json['shippers'] != null ? ShipperModel.fromJson(json['shippers']) : null,
      items: json['order_items'] != null ? (json['order_items'] as List).map((e) => OrderItemModel.fromJson(e)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'shipper_id': shipperId,
      'status': status.toString().split('.').last,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OrderItemModel {
  final int id;
  final int orderId;
  final int foodId;
  final int quantity;
  final double price;
  final FoodModel? food;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.foodId,
    required this.quantity,
    required this.price,
    this.food,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['order_id'],
      foodId: json['food_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      food: json['foods'] != null ? FoodModel.fromJson(json['foods']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'food_id': foodId,
      'quantity': quantity,
      'price': price,
    };
  }
}
