class TailorModel {
  final String brandName;
  final String tagline;
  final String emailAddress;
  final String dialCode;
  final String phoneNumber;
  final String logo;
  final List<Map<String, dynamic>> transactionHistory;
  final double walletBalance;

  final List<String> featuredWorks;

  TailorModel(
      {required this.brandName,
      required this.tagline,
      required this.emailAddress,
      required this.dialCode,
      required this.phoneNumber,
      required this.logo,
      required this.transactionHistory,
      required this.walletBalance,
      required this.featuredWorks});

  factory TailorModel.fromDocument(Map<String, dynamic> doc) {
    return TailorModel(
      brandName: doc['brand_name'],
      tagline: doc['tagline'] ?? '',
      emailAddress: doc['email_address'] ?? '',
      dialCode: doc['dial_code'] ?? '',
      phoneNumber: doc['phone_number'] ?? '',
      logo: doc['logo'] ?? '',
      transactionHistory:
          List<Map<String, dynamic>>.from(doc['transactions'] ?? []),
      walletBalance: doc['wallet'] ?? 0.0,
      featuredWorks: List<String>.from(doc['featured_works'] ?? []),
    );
  }
}
