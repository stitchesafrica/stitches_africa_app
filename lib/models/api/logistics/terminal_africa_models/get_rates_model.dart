class GetRatesModel {
  final String rateId;
  final String deliveryDate;
  final String pickupTime;
  final double shippingFee;

  GetRatesModel(
      {required this.rateId,
      required this.deliveryDate,
      required this.pickupTime,
      required this.shippingFee});

  factory GetRatesModel.fromJson(Map<String, dynamic> json) => GetRatesModel(
      rateId: json['data'].first['rate_id'],
      deliveryDate: json['data'].first['delivery_date'],
      pickupTime: json['data'].first['pickup_time'],
      shippingFee: json['data'].first['amount']);
}
