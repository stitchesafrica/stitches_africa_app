class Bank {
  final String bankCode;
  final String bankName;

  Bank({
    required this.bankCode,
    required this.bankName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      bankCode: json['code'],
      bankName: json['name'],
    );
  }
}

class BankListModel {
  final List<Bank> banks;

  BankListModel({
    required this.banks,
  });

  factory BankListModel.fromJson(Map<String, dynamic> json) {
    final data =
        (json['data'] as List).map((item) => Bank.fromJson(item)).toList();
    return BankListModel(
      banks: data,
    );
  }
}
