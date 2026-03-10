class FoodModel {
  final int id;
  final int restaurantId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final String? restaurantName;

  FoodModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    this.restaurantName,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'],
      restaurantId: json['restaurant_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is String 
          ? double.tryParse(json['price']) ?? 0.0 
          : (json['price'] as num).toDouble(),
      imageUrl: json['image_url'],
      isAvailable: json['is_available'],
      createdAt: DateTime.parse(json['created_at']),
      restaurantName: json['restaurants']?['restaurant_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'restaurant_name': restaurantName,
    };
  }
}
