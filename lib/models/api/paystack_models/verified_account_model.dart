class VerifiedAccountModel {
  final bool status;
  final String accountName;

  VerifiedAccountModel({required this.status, required this.accountName});
  factory VerifiedAccountModel.fromJson(Map<String, dynamic> json) {
    return VerifiedAccountModel(
      status: json['status'],
      accountName: json['data']['account_name'],
    );
  }
}
