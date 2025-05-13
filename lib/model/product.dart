import 'package:firebase_auth/firebase_auth.dart';

class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final List<String> isFavorite;
  final String description;

  Product(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.isFavorite,
      required this.description});

  bool get isLikedByCurrentUser {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && isFavorite.contains(uid);
  }

  factory Product.fromFireStore(Map<String, dynamic> data) {
    return Product(
        id: data['id'],
        name: data['name'],
        imageUrl: data['imageUrl'],
        price: data['price'] ?? "",
        isFavorite: List<String>.from(data['isFavorite'] ?? []),
        description: data["description"] ?? "");
  }
}
