class SingleTransferModel {
  final bool status;
  final String reference;
  final int amount;
  final String transferCode;

  SingleTransferModel(
      {required this.status,
      required this.reference,
      required this.amount,
      required this.transferCode});
  factory SingleTransferModel.fromJson(Map<String, dynamic> json) {
    return SingleTransferModel(
      status: json['status'],
      reference: json['data']['reference'],
      amount: json['data']['amount'],
      transferCode: json['data']['transfer_code'],
    );
  }
}
