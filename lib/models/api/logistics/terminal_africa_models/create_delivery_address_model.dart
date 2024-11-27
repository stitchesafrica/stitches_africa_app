class CreateDeliveryAddressModel {
  final String message;
  final String addressId;

  CreateDeliveryAddressModel({required this.message, required this.addressId});
  factory CreateDeliveryAddressModel.fromJson(Map<String, dynamic> json) =>
      CreateDeliveryAddressModel(
        message: json['message'] as String,
        addressId: json['data']['address_id'] as String,
      );
}
