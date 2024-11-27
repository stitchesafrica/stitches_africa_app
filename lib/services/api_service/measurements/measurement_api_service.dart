import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:stitches_africa/models/api/measurement/person_model.dart';
import 'package:stitches_africa/models/api/measurement/task_set_model.dart';
import 'package:stitches_africa/models/api/measurement/update_person_model.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

class MeasurementApiService {
  final SecureServiceStorage secureStorage = SecureServiceStorage();
  static const String _baseUrl = 'https://saia.3dlook.me/api/v2';

  /// Constructs headers for API requests
  Map<String, String> _buildHeaders(String apiKey) {
    return {
      'Accept': 'application/json',
      'Authorization': 'APIKey $apiKey',
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

  /// Fetches the API key securely
  Future<String> _getApiKey() async {
    final String? apiKey = await secureStorage.retrieveMobileTailorApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }
    return apiKey;
  }

  /// Creates a new person
  Future<PersonModel> createPerson({
    required String gender,
    required int height,
    required double weight,
  }) async {
    try {
      final apiKey = await _getApiKey(); // Fetch the API key
      final Uri url = Uri.parse('$_baseUrl/persons/?measurements_type=all');
      final response = await http
          .post(
            url,
            headers: _buildHeaders(apiKey), // Use the headers helper
            body: jsonEncode({
              "gender": gender,
              "height": height,
              "weight": weight,
            }),
          )
          .timeout(const Duration(
              seconds: 10)); // Add timeout for better error handling
      if (kDebugMode) {
        print('Create Person Response Body: ${response.body}');
      }
      if (response.statusCode == 201) {
        if (kDebugMode) {
          print('Create Person Response Body: ${response.body}');
        }

        // Parse the response and return a `PersonModel`
        return PersonModel.fromJson(jsonDecode(response.body));
      } else {
        // Handle errors using the helper function
        _handleError(response);
      }
    } catch (e) {
      if (kDebugMode) print('Error in createPerson: $e');
      rethrow;
    }

    // Ensures all paths throw or return
    throw Exception('Unexpected error occurred while creating a person.');
  }

  /// Updates person with front and side images
  Future<UpdatePersonModel> updatePerson({
    required int id,
    required File frontImage,
    required File sideImage,
  }) async {
    try {
      final apiKey = await _getApiKey(); // Fetch the API key
      final Uri url = Uri.parse('$_baseUrl/persons/$id/?measurements_type=all');

      // Build multipart request
      final request = http.MultipartRequest('PUT', url);
      request.headers.addAll(_buildHeaders(apiKey));
      request.files.add(await http.MultipartFile.fromPath(
        'front_image',
        frontImage.path,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'side_image',
        sideImage.path,
      ));

      // Send the request
      final response = await request.send();

      if (response.statusCode == 202) {
        final responseBody = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Update Person Response Body: $responseBody');
        }

        // Parse the response and return an `UpdatePersonModel`
        return UpdatePersonModel.fromJson(jsonDecode(responseBody));
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception('API Error: ${response.statusCode} - $responseBody');
      }
    } catch (e) {
      if (kDebugMode) print('Error in updatePerson: $e');
      rethrow;
    }
  }

  /// Fetches a specific task set by ID
  Future<TaskSetModel> getTaskSet(String taskSetId) async {
    try {
      final apiKey = await _getApiKey();
      final Uri url = Uri.parse('$_baseUrl/queue/$taskSetId/');

      final response = await http.get(url, headers: _buildHeaders(apiKey));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return TaskSetModel.fromJson(responseBody);
      } else {
        _handleError(response);
      }
    } catch (e) {
      rethrow;
    }

    // This will never be reached because of the rethrows.
    throw Exception('Unexpected error occurred while fetching task set.');
  }
}
