import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/api_service/notifications/one_signal_api.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/bottom_bar.dart';
import 'package:stitches_africa/views/screens/onboarding/onboarding_first_page.dart';
import 'package:stitches_africa/views/tailor_bottom_bar.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';

class AuthService extends StatelessWidget {
  AuthService({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final OneSignalApi _oneSignalApi = OneSignalApi();

  Timer? cartCheckTimer;

  void startCartCheckTimer() {
    cartCheckTimer = Timer.periodic(const Duration(hours: 1), (timer) async {
      await checkAndSendAbandonedCartNotification();
    });
  }

  Future<void> checkAndSendAbandonedCartNotification() async {
    DateTime? lastCartUpdate = await getLastCartUpdate();
    print(lastCartUpdate);
    if (lastCartUpdate != null) {
      int daysElapsed = DateTime.now().difference(lastCartUpdate).inDays;
      if (daysElapsed >= 2) {
        await _oneSignalApi.sendAbandonedCartNotification();
      }
    }
  }

  Future<DateTime?> getLastCartUpdate() async {
    try {
      final userTags = await OneSignal.User.getTags();
      print(userTags);
      if (userTags.containsKey('last_cart_update')) {
        // Parse and return the DateTime
        return DateTime.parse(userTags['last_cart_update']!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error retrieving last_cart_update: $e");
      }
    }
    return null;
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Utilities.backgroundColor,
                  ),
                );
              } else if (snapshot.connectionState == ConnectionState.none) {
                if (Platform.isIOS) {
                  return IOSAlertDialogWidget(
                      title: 'Error',
                      content:
                          'Unable to connect to the server. Please check your internet connection and try again.',
                      actionButton1: 'Ok',
                      actionButton1OnTap: () {
                        Navigator.pop(context);
                      },
                      isDefaultAction1: true,
                      isDestructiveAction1: false);
                } else {
                  return AndriodAleartDialogWidget(
                      title: 'Error',
                      content:
                          'Unable to connect to the server. Please check your internet connection and try again.',
                      actionButton1: 'Ok',
                      actionButton1OnTap: () {
                        Navigator.pop(context);
                      });
                }
              } else if (snapshot.hasError) {
                if (kDebugMode) {
                  print('Firebase error');
                  print(snapshot.error);
                }
                if (Platform.isIOS) {
                  return IOSAlertDialogWidget(
                      title: 'Error',
                      content: 'Something went wrong, please try again.',
                      actionButton1: 'Ok',
                      actionButton1OnTap: () {
                        Navigator.pop(context);
                      },
                      isDefaultAction1: true,
                      isDestructiveAction1: false);
                } else {
                  return AndriodAleartDialogWidget(
                      title: 'Error',
                      content: 'Something went wrong, please try again.',
                      actionButton1: 'Ok',
                      actionButton1OnTap: () {
                        Navigator.pop(context);
                      });
                }
              } else {
                //snapshot has data
                final User? user = snapshot.data;

                //TODO: RELAY A USER TO THEIR RESPECTIVE BOTTOM BAR
                if (user != null) {
                  String userId = user.uid;
                  // Assign external user ID to OneSignal
                  OneSignal.login(userId);
                  return FutureBuilder<Map<String, dynamic>>(
                      future: firebaseFirestoreFunctions
                          .getUserDataAndStoreLocally(getCurrentUserId()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        } else if (snapshot.hasError) {
                          if (Platform.isIOS) {
                            return IOSAlertDialogWidget(
                                title: 'Error',
                                content:
                                    'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                                actionButton1: 'Ok',
                                actionButton1OnTap: () {
                                  Navigator.pop(context);
                                },
                                isDefaultAction1: true,
                                isDestructiveAction1: false);
                          } else {
                            return AndriodAleartDialogWidget(
                                title: 'Error',
                                content:
                                    'Unable to connect to the server. Please check your internet connection and try again.',
                                actionButton1: 'Ok',
                                actionButton1OnTap: () {
                                  Navigator.pop(context);
                                });
                          }
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text(
                            'No user data available',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                            ),
                          ));
                        }
                        final userData = snapshot.data!;

                        if (userData['is_tailor']) {
                          return TailorBottomBar();
                        } else {
                          startCartCheckTimer();
                          //navigate to user side
                          return MyBottomBar();
                        }
                      });
                } else {
                  return OnBoardingFirstPage();
                }
              }
            }));
  }
}
