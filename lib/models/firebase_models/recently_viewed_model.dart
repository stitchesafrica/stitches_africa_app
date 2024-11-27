class RecentlyViewedModel {
  final String productId;
  final String image;

  RecentlyViewedModel({required this.productId, required this.image});
  factory RecentlyViewedModel.fromDocument(Map<String, dynamic> doc) {
    return RecentlyViewedModel(
      productId: doc["product_id"],
      image: doc["image"],
    );
  }
}
