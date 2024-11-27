import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureServiceStorage {
  final storage = const FlutterSecureStorage();

  Future<void> storeAlphaVantageApiKey() async {
    final apiKey = dotenv.env['ALPHAVANTAGE_PRICE_API_KEY'];
    await storage.write(key: 'ALPHAVANTAGE_PRICE_API_KEY', value: apiKey);
    print('alpha vantage api key stored successfully');
  }

  Future<void> storeMobileTailorApiKey() async {
    final apiKey = dotenv.env['MOBILE_TAILOR_API_KEY'];
    await storage.write(key: 'MOBILE_TAILOR_API_KEY', value: apiKey);
  }

  Future<void> storeOneSignalApiKey() async {
    final apiKey = dotenv.env['ONESIGNAL_API_KEY'];
    await storage.write(key: 'ONESIGNAL_API_KEY', value: apiKey);
  }

  Future<void> storePaystackApiKey() async {
    final apiKey = dotenv.env['LIVE_PUBLIC_KEY'];
    await storage.write(key: 'LIVE_PUBLIC_KEY', value: apiKey);
    print('paystack api key stored successfully');
  }

  Future<void> storePaystackSecretApiKey() async {
    final apiKey = dotenv.env['LIVE_SECRET_KEY'];
    await storage.write(key: 'LIVE_SECRET_KEY', value: apiKey);
    print('paystack api key stored successfully');
  }

  Future<void> storeTerminalAfricaSecretApiKey() async {
    final apiKey = dotenv.env['TERMINAL_AFRICA_LIVE_SECRET_KEY'];
    await storage.write(key: 'TERMINAL_AFRICA_LIVE_SECRET_KEY', value: apiKey);
    print('Terminal Africa secret key stored successfully');
  }

  Future<String?> retrieveAlphaVantageApiKey() async {
    return await storage.read(key: 'ALPHAVANTAGE_PRICE_API_KEY');
  }

  Future<String?> retrieveMobileTailorApiKey() async {
    return await storage.read(key: 'MOBILE_TAILOR_API_KEY');
  }

  Future<String?> retrieveOneSignalApiKey() async {
    return await storage.read(key: 'ONESIGNAL_API_KEY');
  }

  Future<String?> retrievePaystackApiKey() async {
    return await storage.read(key: 'LIVE_PUBLIC_KEY');
  }

  Future<String?> retrievePaystackSecretApiKey() async {
    return await storage.read(key: 'LIVE_SECRET_KEY');
  }

  Future<String?> retrieveTerminalAfricaSecretApiKey() async {
    return await storage.read(key: 'TERMINAL_AFRICA_LIVE_SECRET_KEY');
  }
}
