import 'dart:ffi';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String description;
  bool favourite;
  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.favourite,
  });

  factory Product.fromFireStore(Map<String, dynamic> data) {
    return Product(
        id: data["id"] ?? "",
        name: data["name"] ?? "",
        imageUrl: data["imageUrl"] ?? "",
        price: data["price"] ?? "",
        description: data["description"] ?? "",
        favourite: data["favourite"] ?? false);
  }
}
