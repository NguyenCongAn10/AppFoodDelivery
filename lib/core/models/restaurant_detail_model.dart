import 'package:delivery_apps/core/models/food_model.dart';

class RestaurantDetailModel {
  final int id;
  final String name;
  final String address;
  final double rating;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final List<MenuCategory> menu;

  RestaurantDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.menu,
  });

  factory RestaurantDetailModel.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailModel(
      id: json['id'] as int,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      menu: (json['menu'] as List<dynamic>?)
              ?.map((categoryJson) => MenuCategory.fromJson(categoryJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class MenuCategory {
  final String categoryName;
  final List<FoodModel> foods;

  MenuCategory({
    required this.categoryName,
    required this.foods,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      categoryName: json['category_name'] ?? 'Others',
      foods: (json['foods'] as List<dynamic>?)
              ?.map((foodJson) => FoodModel.fromJson(foodJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
