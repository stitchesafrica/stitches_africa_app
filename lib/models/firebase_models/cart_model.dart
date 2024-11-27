class CartModel {
  final List<String> images;
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final int totalItems;

  CartModel({
    required this.images,
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.totalItems,
  });
  factory CartModel.fromDocument(Map<String, dynamic> doc, {int? totalItems}) {
    return CartModel(
      images: List<String>.from(doc['images'] ?? []),
      id: doc['id'],
      productId: doc['product_id'],
      title: doc['title'] ?? '',
      price: doc['price'].toDouble() ?? 0.0,
      quantity: doc['quantity'].toInt() ?? 1,
      totalItems: totalItems ?? 0,
    );
  }
}
