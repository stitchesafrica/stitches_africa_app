import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stitches_africa/models/api/price_model.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

class PriceServiceApi {
  //initialize storage
  final secureStorage = SecureServiceStorage();
  static const BASE_URL = 'https://api.fastforex.io';
  static const METAL_BASE_URL = 'https://api.metals.dev/v1/metal';

  Future<Price> getForexPrice(String baseCurrency, String quoteCurrency) async {
    String? apiKey = await secureStorage.retrieveAlphaVantageApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }
    final response = await http.get(
      Uri.parse(
        '$BASE_URL/fetch-one?from=$baseCurrency&to=$quoteCurrency&api_key=$apiKey',
      ),
    );
    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }
      return Price.fromJson(jsonDecode(response.body), quoteCurrency);
    } else {
      throw Exception('Failed to load price data${response.body}');
    }
  }
}
