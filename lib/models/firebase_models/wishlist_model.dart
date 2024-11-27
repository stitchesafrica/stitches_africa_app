class WishlistModel {
  final List<String> images;
  final String id;
  final String productId;
  final String title;
  final String description;
  final double price;

  WishlistModel(
      {required this.images,
      required this.id,
      required this.productId,
      required this.title,
      required this.description,
      required this.price});

  factory WishlistModel.fromDocument(Map<String, dynamic> doc) {
    return WishlistModel(
      images: List<String>.from(doc['images'] ?? []),
      id: doc['id'],
      productId: doc['product_id'],
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      price: doc['price'].toDouble() ?? 0.0,
    );
  }
}
