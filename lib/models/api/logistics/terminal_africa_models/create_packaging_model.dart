class CreatePackagingModel {
  final String packagingId;

  CreatePackagingModel({required this.packagingId});

  factory CreatePackagingModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return CreatePackagingModel(
      packagingId: data['packaging_id'],
    );
  }
}
