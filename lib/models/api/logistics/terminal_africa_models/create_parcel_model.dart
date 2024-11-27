class CreateParcelModel {
  final String parcelId;

  CreateParcelModel({required this.parcelId});
  factory CreateParcelModel.fromJson(Map<String, dynamic> json) =>
      CreateParcelModel(
        parcelId: json['data']['parcel_id'] as String,
      );
}
