class MatchedFood {
  final int id;
  final String name;
  final double price;
  final String? imageUrl;

  MatchedFood({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
  });

  factory MatchedFood.fromJson(Map<String, dynamic> json) {
    return MatchedFood(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      price: json['price'] is String
          ? double.tryParse(json['price'] as String) ?? 0.0
          : (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
    );
  }
}

class RestaurantSearchResult {
  final int id;
  final String name;
  final double rating;
  final int ratingCount;
  final double? distanceKm;
  final String address;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final List<MatchedFood> matchedFoods;

  RestaurantSearchResult({
    required this.id,
    required this.name,
    required this.rating,
    required this.ratingCount,
    required this.distanceKm,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.matchedFoods,
  });

  factory RestaurantSearchResult.fromJson(Map<String, dynamic> json) {
    final foodsJson = (json['matched_foods'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return RestaurantSearchResult(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      rating: (json['rating'] is String)
          ? double.tryParse(json['rating'] as String) ?? 0.0
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['rating_count'] as int?) ?? 0,
      distanceKm: json['distance_km'] != null
          ? (json['distance_km'] as num).toDouble()
          : null,
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      matchedFoods: foodsJson.map(MatchedFood.fromJson).toList(),
    );
  }
}

