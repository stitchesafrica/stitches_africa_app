import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';

class OneSignalApi {
  //initialize storage
  final secureStorage = SecureServiceStorage();

  Future<void> sendWelcomeNotifcation(String title, String content) async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }
    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'headings': {"en": title},
          'contents': {'en': content},
          'app_id': '6a1b03c9-c01b-4713-8e65-d50088059721',
          'name': 'Stitches Africa',
          'included_segments': ['New Users'],
        }),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Notification sent successfully');
          OneSignal.User.addTags({"welcome_sent": "true"});
        }
      } else {
        throw Exception;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendAbandonedCartNotification() async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    String? externalUserId = await OneSignal.User.getExternalId();
    if (externalUserId == null) {
      throw Exception('External User ID not set for the current user.');
    }

    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'app_id': '6a1b03c9-c01b-4713-8e65-d50088059721',
          'headings': {"en": 'Abandoned Cart'},
          'contents': {
            'en': 'You left items in your cart! Complete your purchase now.'
          },
          'include_external_user_ids': [externalUserId],
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Abandoned cart notification sent to current user.');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send abandoned cart notification: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending abandoned cart notification: $e');
      }
    }
  }

  Future<void> sendOrderStatusNotification(
      String userExternalId, String orderStatus) async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': '6a1b03c9-c01b-4713-8e65-d50088059721',
          'headings': {"en": 'Order Update'},
          'contents': {
            'en':
                'Your order is now $orderStatus. Thank you for shopping with us!'
          },
          'include_external_user_ids': [userExternalId],
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Order status notification sent to user: $userExternalId');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send order status notification: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending order status notification: $e');
      }
    }
  }

  Future<void> sendAfterPurchaseNotification(String userExternalId) async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': '6a1b03c9-c01b-4713-8e65-d50088059721',
          'headings': {"en": 'Thank You for Your Purchase!'},
          'contents': {
            'en':
                'We appreciate your order! Your items will be with you soon. Have a great day!'
          },
          'include_external_user_ids': [userExternalId],
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Post-purchase notification sent to user: $userExternalId');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send post-purchase notification: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending post-purchase notification: $e');
      }
    }
  }

  Future<void> sendTailorOrderNotification(String tailorExternalId) async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }

    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'app_id': '6a1b03c9-c01b-4713-8e65-d50088059721',
          'headings': {"en": 'New Order!'},
          'contents': {
            'en':
                'You have received a new order. Please check your dashboard for details.'
          },
          'include_external_user_ids': [tailorExternalId],
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('New order notification sent to tailor: $tailorExternalId');
        }
      } else {
        if (kDebugMode) {
          print('Failed to send new order notification: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending new order notification: $e');
      }
    }
  }

  Future<void> sendEditSignalNotification(String title, String content) async {
    String? apiKey = await secureStorage.retrieveOneSignalApiKey();
    if (apiKey == null) {
      throw Exception('API key not found');
    }
    Uri url = Uri.parse('https://api.onesignal.com/notifications');

    try {
      var response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Basic $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'headings': {"en": title},
          'contents': {'en': content},
          'app_id': 'a064b308-7c23-4806-b04a-dd9f8015282f',
          'name': 'Firepips',
          'included_segments': ['Total Subscriptions'],
          "android_channel_id": "885f833d-8524-4fe6-a414-1838fc91c97f"
        }),
      );
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        throw Exception;
      }
    } catch (e) {
      rethrow;
    }
  }
}
