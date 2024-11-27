class CreatePickupAddressModel {
  final String addressId;

  CreatePickupAddressModel({required this.addressId});
  factory CreatePickupAddressModel.fromJson(Map<String, dynamic> json) =>
      CreatePickupAddressModel(
        addressId: json['data']['address_id'] as String,
      );
}
