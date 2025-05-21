class CartItem {
  final String id;
  final String productId;
  final String name;
  final String imageUrl;
  final String price;
  String quantity;

  CartItem(
      {required this.id,
      required this.productId,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.quantity});

  factory CartItem.fromFireStore(Map<String, dynamic> data, String docId) {
    return CartItem(
        id: docId,
        productId: data["productId"] ?? "",
        name: data["name"] ?? "",
        imageUrl: data["imageUrl"] ?? "",
        price: data["price"] ?? "",
        quantity: data["quantity"] ?? "");
  }

  Map<String, dynamic> toMap() {
    return {
      "productId": productId,
      "name": name,
      "imageUrl": imageUrl,
      "price": price,
      "quantity": quantity
    };
  }
}
