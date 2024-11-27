class OrderModel {
  final String orderId;
  final String tailorId;
  final String userId;
  final String productId;
  final String title;
  final int quantity;
  final double price;
  final String orderStatus;
  final String deliveryDate;
  final List<String> images;
  final Map<String, dynamic> userAddress;
  final DateTime timestamp;

  OrderModel(
      {required this.orderId,
      required this.tailorId,
      required this.userId,
      required this.productId,
      required this.title,
      required this.quantity,
      required this.price,
      required this.orderStatus,
      required this.deliveryDate,
      required this.images,
      required this.userAddress,
      required this.timestamp});

  factory OrderModel.fromDocument(Map<String, dynamic> doc) {
    return OrderModel(
      orderId: doc['order_id'],
      tailorId: doc['tailor_id'],
      userId: doc['user_id'],
      productId: doc['product_id'],
      title: doc['title'] ?? '',
      quantity: doc['quantity'] ?? 1,
      price: doc['price'] ?? 0.0,
      orderStatus: doc['order_status'] ?? 'pending',
      deliveryDate: doc['delivery_date'],
      images: List<String>.from(doc['images'] ?? []),
      userAddress: Map<String, dynamic>.from(doc['user_address']),
      timestamp: doc['timestamp'].toDate() ?? '',
    );
  }
}
