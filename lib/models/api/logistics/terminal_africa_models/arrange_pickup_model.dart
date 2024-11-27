class ArrangePickupModel {
  final String trackingNumber;
  final String trackingUrl;

  ArrangePickupModel({required this.trackingNumber, required this.trackingUrl});

  factory ArrangePickupModel.fromJson(Map<String, dynamic> json) =>
      ArrangePickupModel(
        trackingNumber: json['data']['extras']['tracking_number'] as String,
        trackingUrl: json['data']['extras']['tracking_url'] as String,
      );
}
