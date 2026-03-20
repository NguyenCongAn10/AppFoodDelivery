class FoodModel {
  final int id;
  final int restaurantId;
  final int? categoryId;
  final String? categoryName;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;
  final String? restaurantName;
  final int? quantity;
  final List<FoodOptionGroupModel> optionGroups;

  FoodModel({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
    this.restaurantName,
    this.quantity,
    this.optionGroups = const [],
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? 0,
      categoryId: json['category_id'],
      categoryName: json['categories']?['name'],
      name: json['name'] ?? '',
      description: json['description'],
      price: json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      restaurantName: json['restaurants']?['restaurant_name'],
      quantity: json['quantity'],
      optionGroups: (json['option_groups'] as List?)
              ?.map((og) => FoodOptionGroupModel.fromJson(og))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'category_id': categoryId,
      'category_name': categoryName,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'restaurant_name': restaurantName,
      'quantity': quantity,
      'option_groups': optionGroups.map((og) => og.toJson()).toList(),
    };
  }
}

class FoodOptionGroupModel {
  final int id;
  final String name;
  final bool isRequired;
  final String selectionType; // 'SINGLE' or 'MULTIPLE'
  final List<FoodOptionModel> options;

  FoodOptionGroupModel({
    required this.id,
    required this.name,
    required this.isRequired,
    required this.selectionType,
    required this.options,
  });

  factory FoodOptionGroupModel.fromJson(Map<String, dynamic> json) {
    return FoodOptionGroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isRequired: json['is_required'] ?? false,
      selectionType: json['selection_type'] ?? 'SINGLE',
      options: (json['options'] as List?)
              ?.map((o) => FoodOptionModel.fromJson(o))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_required': isRequired,
      'selection_type': selectionType,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class FoodOptionModel {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;

  FoodOptionModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
  });

  factory FoodOptionModel.fromJson(Map<String, dynamic> json) {
    return FoodOptionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
