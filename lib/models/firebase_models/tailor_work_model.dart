class TailorWorkModel {
  final List<String> images;
  final String tailorWorkID;
  final String productId;
  final String title;
  final String description;
  final double price;

  TailorWorkModel(
      {required this.images,
      required this.tailorWorkID,
      required this.productId,
      required this.title,
      required this.description,
      required this.price});

  factory TailorWorkModel.fromDocument(Map<String, dynamic> doc) {
    return TailorWorkModel(
      images: List<String>.from(doc['images'] ?? []),
      tailorWorkID: doc['id'],
      productId: doc['product_id'],
      title: doc['title'] ?? '',
      description: doc['description'] ?? '',
      price: doc['price'].toDouble() ?? 0.0,
    );
  }
}
