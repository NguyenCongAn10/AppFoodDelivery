class CartItem {
  final String id;
  final String productId;
  final String restaurantId;
  final String name;
  final String imageUrl;
  final String price;
  String quantity;

  CartItem({
    required this.id,
    required this.productId,
    this.restaurantId = '',
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromFireStore(Map<String, dynamic> data, String docId) {
    return CartItem(
      id: docId,
      productId: data["productId"] ?? "",
      restaurantId: data["restaurantId"] ?? "",
      name: data["name"] ?? "",
      imageUrl: data["imageUrl"] ?? "",
      price: data["price"] ?? "",
      quantity: data["quantity"] ?? "",
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final food = json['foods'] as Map<String, dynamic>? ?? {};
    final restaurant = food['restaurants'] as Map<String, dynamic>? ?? {};

    return CartItem(
      id: json['id']?.toString() ?? '',
      productId: json['food_id']?.toString() ?? json['productId']?.toString() ?? '',
      restaurantId: restaurant['id']?.toString() ?? json['restaurant_id']?.toString() ?? json['restaurantId']?.toString() ?? '',
      name: food['name']?.toString() ?? json['name']?.toString() ?? '',
      imageUrl: food['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      price: food['price']?.toString() ?? json['price']?.toString() ?? '0',
      quantity: json['quantity']?.toString() ?? '1',
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    return {
      if (includeId) 'id': id,
      'productId': productId,
      'restaurantId': restaurantId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
    };
  }
}
