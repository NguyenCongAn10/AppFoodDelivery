import 'package:delivery_apps/core/models/food_model.dart';

class RestaurantModel {
  final int id;
  final String userUid;
  final String restaurantName;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int ratingCount;
  final String? phone;
  final bool isOpen;
  final DateTime createdAt;
  final List<FoodModel>? foods;
  RestaurantModel({
    required this.id,
    required this.userUid,
    required this.restaurantName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.ratingCount,
    this.phone,
    required this.isOpen,
    required this.createdAt,
    this.foods,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      userUid: json['user_uid']?.toString() ?? json['user_id']?.toString() ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      address: json['address'] ?? '',
      latitude: json['latitude'] is String 
          ? double.tryParse(json['latitude']) ?? 0.0 
          : (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: json['longitude'] is String 
          ? double.tryParse(json['longitude']) ?? 0.0 
          : (json['longitude'] as num?)?.toDouble() ?? 0.0,
      rating: json['rating'] is String 
          ? double.tryParse(json['rating']) ?? 0.0 
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] ?? 0,
      phone: json['phone'],
      isOpen: json['is_open'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      foods: (json['foods'] as List<dynamic>?)
          ?.map((e) => FoodModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uid': userUid,
      'restaurant_name': restaurantName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'rating_count': ratingCount,
      'phone': phone,
      'is_open': isOpen,
      'created_at': createdAt.toIso8601String(),
      'foods': foods?.map((food) => food.toJson()).toList(),

    };
  }
}
