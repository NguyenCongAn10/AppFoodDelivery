class Category {
  final String id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromFireStore(Map<String, dynamic> data) {
    return Category(
      id: data["id"]?.toString()??"",
      name: data["name"] ?.toString()?? "",
      image: data["imageUrl"] ?.toString()?? "",
    );
  }
}