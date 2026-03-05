class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final List<String> isFavorite;
  final String description;
  String? categoryId;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.isFavorite,
    required this.description,
    required this.categoryId,
  });

  bool isLikedBy(String? uid) {
    return uid != null && isFavorite.contains(uid);
  }

  factory Product.fromFireStore(Map<String, dynamic> data) {
    return Product(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: data['price'] ?? '',
      isFavorite: List<String>.from(data['isFavorite'] ?? []),
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price'].toString(),
      isFavorite: [],
      description: json['description'] ?? '',
      categoryId: json['restaurant_id'].toString(),
    );
  }
}
