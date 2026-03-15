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
  final String userUid;
  final int restaurantId;
  final int? shipperId;
  final OrderStatus status;
  final double totalPrice;
  final DateTime createdAt;
  final UserModel? user;
  final RestaurantModel? restaurant;
  final ShipperModel? shipper;
  final String? deliveryAddress;
  final String? paymentMethod;
  final double? deliveryLat;
  final double? deliveryLng;
  final double? shipperLat;
  final double? shipperLng;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userUid,
    required this.restaurantId,
    this.shipperId,
    required this.status,
    required this.totalPrice,
    required this.createdAt,
    this.user,
    this.restaurant,
    this.shipper,
    this.deliveryAddress,
    this.paymentMethod,
    this.deliveryLat,
    this.deliveryLng,
    this.shipperLat,
    this.shipperLng,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      userUid: json['user_uid']?.toString() ?? json['user_id']?.toString() ?? '',
      restaurantId: json['restaurant_id'] ?? 0,
      shipperId: json['shipper_id'],
      status: OrderStatus.values.firstWhere((e) => e.toString().split('.').last == json['status'], orElse: () => OrderStatus.PENDING),
      totalPrice: json['total_price'] is String 
          ? double.tryParse(json['total_price']) ?? 0.0 
          : (json['total_price'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['delivery_address'],
      paymentMethod: json['payment_method'],
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      shipperLat: (json['shipper_lat'] as num?)?.toDouble(),
      shipperLng: (json['shipper_lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      user: json['users'] != null ? UserModel.fromJson(json['users']) : null,
      restaurant: json['restaurants'] != null ? RestaurantModel.fromJson(json['restaurants']) : null,
      shipper: json['shippers'] != null ? ShipperModel.fromJson(json['shippers']) : null,
      items: json['order_items'] != null ? (json['order_items'] as List).map((e) => OrderItemModel.fromJson(e)).toList() : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uid': userUid,
      'restaurant_id': restaurantId,
      'shipper_id': shipperId,
      'status': status.toString().split('.').last,
      'total_price': totalPrice,
      'delivery_address': deliveryAddress,
      'payment_method': paymentMethod,
      'delivery_lat': deliveryLat,
      'delivery_lng': deliveryLng,
      'shipper_lat': shipperLat,
      'shipper_lng': shipperLng,
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
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      foodId: json['food_id'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: json['price'] is String 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price'] as num?)?.toDouble() ?? 0.0,
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
