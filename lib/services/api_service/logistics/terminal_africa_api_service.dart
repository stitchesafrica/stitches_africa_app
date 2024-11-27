import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/arrange_pickup_model.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_delivery_address_model.dart';

import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_packaging_model.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_parcel_model.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_pickup_address_model.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/create_shipment_model.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/get_rates_model.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

class TerminalAfricaApiService {
  final SecureServiceStorage secureStorage = SecureServiceStorage();
  static const String _baseUrl = 'https://api.terminal.africa/v1';

  /// Constructs headers for API requests
  Map<String, String> _buildHeaders(String secretKey) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $secretKey',
      'Content-Type': 'application/json',
    };
  }

  /// Handles API errors by throwing meaningful exceptions
  void _handleError(http.Response response) {
    try {
      final errorResponse = jsonDecode(response.body);
      throw Exception(
        'API Error: ${response.statusCode} - ${errorResponse['message'] ?? 'Unknown error'}',
      );
    } catch (_) {
      throw Exception(
          'Error: ${response.statusCode} - Unable to parse response.');
    }
  }

  /// Fetches the API secret key
  Future<String> _getSecretKey() async {
    final String? secretKey =
        await secureStorage.retrieveTerminalAfricaSecretApiKey();
    if (secretKey == null) {
      throw Exception('API key not found');
    }
    return secretKey;
  }

  /// Creates packaging
  Future<CreatePackagingModel> createPackaging({
    required double height,
    required double length,
    required double width,
    required double weight,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/packaging');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "height": height,
              "length": length,
              "name": "Box Packaging",
              "size_unit": "cm",
              "type": "box",
              "width": width,
              "weight": weight,
              "weight_unit": "kg",
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Create Packaging Response Body: ${response.body}');
        }

        return CreatePackagingModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createPackaging: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while creating packaging.');
  }

  /// Fetches rates for shipment
  Future<GetRatesModel> getRates({
    required String pickUpAddressId,
    required String deliveryAddressId,
    required String parcelId,
    required bool cashOnDelivery,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/rates/shipment').replace(
        queryParameters: {
          'currency': 'USD',
          'pickup_address': pickUpAddressId,
          'delivery_address': deliveryAddressId,
          'parcel_id': parcelId,
          'cash_on_delivery': cashOnDelivery.toString(),
        },
      );

      final response = await http
          .get(
            url,
            headers: _buildHeaders(secretKey),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) print('Get Rates Response Body: ${response.body}');
        return GetRatesModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in getRates: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while fetching rates.');
  }

  /// Creates a pickup address
  Future<CreatePickupAddressModel> createPickupAddress({
    required String city,
    required String countryCode,
    required String email,
    required bool isResidential,
    required String firstName,
    required String lastName,
    required String line1,
    required String phone,
    required String state,
    required String postalCode,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/addresses');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "city": city,
              "country": countryCode,
              "email": email,
              "first_name": firstName,
              "is_residential": isResidential,
              "last_name": lastName,
              "line1": line1,
              "name": '$firstName $lastName',
              "phone": phone,
              "state": state,
              "zip": postalCode,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Create Pickup Address Response Body: ${response.body}');
        }

        return CreatePickupAddressModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createPickupAddress: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while creating pickup address.');
  }

  /// Creates a delivery address
  Future<CreateDeliveryAddressModel> createDeliveryAddress({
    required String city,
    required String countryCode,
    required String email,
    required bool isResidential,
    required String firstName,
    required String lastName,
    required String line1,
    required String phone,
    required String state,
    required String postalCode,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/addresses');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "city": city,
              "country": countryCode,
              "email": email,
              "first_name": firstName,
              "is_residential": isResidential,
              "last_name": lastName,
              "line1": line1,
              "name": '$firstName $lastName',
              "phone": phone,
              "state": state,
              "zip": postalCode,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Create Delivery Address Response Body: ${response.body}');
        }
        return CreateDeliveryAddressModel.fromJson(jsonDecode(response.body));
      } else {
        throw response; // Throw response to handle in catch block
      }
    } on http.Response catch (response) {
      try {
        // Parse the error response body into CreateDeliveryAddressModel
        final errorModel =
            CreateDeliveryAddressModel.fromJson(jsonDecode(response.body));
        throw errorModel.message; // Rethrow parsed model
      } catch (_) {
        final responseBody = jsonDecode(response.body);

        // In case parsing fails, throw a general exception
        throw Exception('${responseBody['message']}');
      }
    } catch (e) {
      if (kDebugMode) print('Error in createDeliveryAddress: $e');
      rethrow; // Rethrow for other errors
    }
  }

  /// Creates a parcel
  Future<CreateParcelModel> createParcel({
    required String description,
    required String packagingId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/parcels');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "description": description,
              "items": items,
              "packaging": packagingId,
              "weight_unit": "kg",
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) print('Create Parcel Response Body: ${response.body}');
        return CreateParcelModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createParcel: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while creating parcel.');
  }

  /// Creates a shipment
  Future<CreateShipmentModel> createShipment({
    required String pickUpAddressId,
    required String deliveryAddressId,
    required String parcelId,
    required String addressReturnId,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/shipments');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "address_from": pickUpAddressId,
              "address_to": deliveryAddressId,
              "address_return": addressReturnId,
              "parcel": parcelId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Create Shipment Response Body: ${response.body}');
        }

        return CreateShipmentModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createShipment: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while creating shipment.');
  }

  /// Arranges a pickup
  Future<ArrangePickupModel> arrangePickup({
    required String rateId,
    required String shipmentId,
  }) async {
    try {
      final secretKey = await _getSecretKey();
      final Uri url = Uri.parse('$_baseUrl/shipments/pickup');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(secretKey),
            body: jsonEncode({
              "rate_id": rateId,
              "shipment_id": shipmentId,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print(jsonDecode(response.body));

      if (response.statusCode == 200) {
        if (kDebugMode) print('Arrange Pickup Response Body: ${response.body}');
        return ArrangePickupModel.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in arrangePickup: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while arranging pickup.');
  }
}
