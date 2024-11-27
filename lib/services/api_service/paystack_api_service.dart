import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stitches_africa/models/api/paystack_models/bank_list_model.dart';
import 'package:stitches_africa/models/api/paystack_models/single_transfer_model.dart';
import 'package:stitches_africa/models/api/paystack_models/transfer_receipent_model.dart';
import 'package:stitches_africa/models/api/paystack_models/verified_account_model.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

class PaystackApiService {
  final SecureServiceStorage _secureStorage = SecureServiceStorage();
  static const String _baseUrl = 'https://api.paystack.co';

  /// Retrieves the list of banks
  Future<BankListModel> getBankList() async {
    final String? secretKey =
        await _secureStorage.retrievePaystackSecretApiKey();
    if (secretKey == null) {
      throw Exception('API key not found');
    }

    final Uri url = Uri.parse('$_baseUrl/bank');

    try {
      final response = await http.get(
        url,
        headers: _buildHeaders(secretKey),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print('Bank List Response: ${response.body}');
        return BankListModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in getBankList: $e');
      rethrow;
    }

    // To satisfy Dart's type checking in case all other paths are missed
    throw Exception('Unexpected error while fetching bank list.');
  }

  /// Verifies a bank account
  Future<VerifiedAccountModel> verifyAccount(
      String accountNumber, String bankCode) async {
    final String? secretKey =
        await _secureStorage.retrievePaystackSecretApiKey();
    if (secretKey == null) {
      throw Exception('API key not found');
    }

    final Uri url = Uri.parse('$_baseUrl/bank/resolve').replace(
      queryParameters: {
        'account_number': accountNumber,
        'bank_code': bankCode,
      },
    );

    try {
      final response = await http.get(
        url,
        headers: _buildHeaders(secretKey),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print('Verify Account Response: ${response.body}');
        return VerifiedAccountModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in verifyAccount: $e');
      rethrow;
    }

    throw Exception('Unexpected error while verifying account.');
  }

  /// Creates a transfer recipient
  Future<TransferReceipentModel> createTransferRecipient(
      String accountName, String accountNumber, String bankCode) async {
    final String? secretKey =
        await _secureStorage.retrievePaystackSecretApiKey();
    if (secretKey == null) {
      throw Exception('API key not found');
    }

    final Uri url = Uri.parse('$_baseUrl/transferrecipient');

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(secretKey),
        body: jsonEncode({
          "type": "nuban",
          "name": accountName,
          "account_number": accountNumber,
          "bank_code": bankCode,
          "currency": "NGN",
        }),
      );

      if (response.statusCode == 201) {
        if (kDebugMode)
          print('Create Transfer Recipient Response: ${response.body}');
        return TransferReceipentModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createTransferRecipient: $e');
      rethrow;
    }

    throw Exception('Unexpected error while creating transfer recipient.');
  }

  /// Initiates a transfer
  Future<SingleTransferModel> initiateTransfer(
      int amount, String referenceCode, String recipientCode) async {
    final String? secretKey =
        await _secureStorage.retrievePaystackSecretApiKey();
    if (secretKey == null) {
      throw Exception('API key not found');
    }

    final Uri url = Uri.parse('$_baseUrl/transfer');

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(secretKey),
        body: jsonEncode({
          "source": "balance",
          "amount": amount,
          "reference": referenceCode,
          "recipient": recipientCode,
          "reason": "Withdrawal",
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) print('Initiate Transfer Response: ${response.body}');
        return SingleTransferModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in initiateTransfer: $e');
      rethrow;
    }

    throw Exception('Unexpected error while initiating transfer.');
  }

  /// Builds request headers
  Map<String, String> _buildHeaders(String secretKey) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
  }

  /// Handles API errors by parsing and throwing meaningful exceptions
  void _handleError(http.Response response) {
    try {
      final errorResponse = jsonDecode(response.body);
      throw Exception(
        'Error: ${response.statusCode} - ${errorResponse['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      throw Exception(
          'Error: ${response.statusCode} - Failed to parse error response.');
    }
  }
}
