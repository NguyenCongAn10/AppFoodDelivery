class RestaurantModel {
  final int id;
  final int userId;
  final String restaurantName;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final int ratingCount;
  final String? phone;
  final bool isOpen;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.userId,
    required this.restaurantName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.ratingCount,
    this.phone,
    required this.isOpen,
    required this.createdAt,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'],
      userId: json['user_id'],
      restaurantName: json['restaurant_name'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['rating_count'],
      phone: json['phone'],
      isOpen: json['is_open'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_name': restaurantName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'rating_count': ratingCount,
      'phone': phone,
      'is_open': isOpen,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
