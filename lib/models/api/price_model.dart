class Price {
  final String baseCurrencyCode;
  final double currencyExchangeRate;
  final String lastRefreshed;

  Price(
      {required this.baseCurrencyCode,
      required this.currencyExchangeRate,
      required this.lastRefreshed});

  factory Price.fromJson(Map<String, dynamic> json, String quote) {
    return Price(
        baseCurrencyCode: json['base'],
        currencyExchangeRate: (json['result'][quote]).toDouble(),
        lastRefreshed: json['updated']);
  }
}
