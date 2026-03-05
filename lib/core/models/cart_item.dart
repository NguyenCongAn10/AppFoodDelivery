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
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'],
      quantity: json['quantity'],
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
