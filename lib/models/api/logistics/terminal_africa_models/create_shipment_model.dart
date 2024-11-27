class CreateShipmentModel {
  final String shipmentId;

  CreateShipmentModel({required this.shipmentId});
  factory CreateShipmentModel.fromJson(Map<String, dynamic> json) =>
      CreateShipmentModel(
        shipmentId: json['data']['shipment_id'] as String,
      );
}
