class TransferReceipentModel {
  final String recepientCode;

  TransferReceipentModel({required this.recepientCode});

  factory TransferReceipentModel.fromJson(Map<String, dynamic> json) {
    return TransferReceipentModel(
      recepientCode: json['data']['recipient_code'],
    );
  }
}
