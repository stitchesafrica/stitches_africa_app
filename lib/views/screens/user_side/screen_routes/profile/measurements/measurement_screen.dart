// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/user_measurement_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/user_side/measurements/measurments_list.dart';
import 'package:toastification/toastification.dart';

class MeasurementScreen extends ConsumerWidget {
  MeasurementScreen({super.key});

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification _showToasitification = ShowToasitification();

  /// Displays a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );
  }

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  double inchesToCm(double inches) {
    const double inchToCmFactor = 2.54; // 1 inch = 2.54 cm
    return inches * inchToCmFactor;
  }

  Stream<UserMeasurementModel> getUserMeasurementStream() {
    return FirebaseFirestore.instance
        .collection('users_measurements')
        .doc(_getCurrentUserId())
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return UserMeasurementModel.fromDocument(data); // Convert to model
      } else {
        throw Exception('Measurement data not found for the user');
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              'YOUR MEASUREMENT',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                // letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
                child: MeasurmentsList(
              getUserMeasurementStream: getUserMeasurementStream(),
            ))
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
          border: false,
          text: 'Save Measurement',
          onTap: () async {
            final updatedFields = ref.read(updatedFieldsProvider);

            // Process updated fields to remove "in" and convert back to cm
            final Map<String, dynamic> processedFields = {};
            updatedFields.forEach((key, value) {
              if (value is String && value.endsWith(" in")) {
                // Remove " in" and convert back to cm
                final inchesValue =
                    double.tryParse(value.replaceAll(" in", ""));
                if (inchesValue != null) {
                  processedFields[key] = inchesToCm(inchesValue);
                }
              } else {
                processedFields[key] = inchesToCm(value);
              }
            });

            _showLoadingDialog(context);

            // Update Firebase with processed fields
            await _firebaseFirestoreFunctions.updateUserMeasurementFields(
              _getCurrentUserId(),
              processedFields,
            );

            context.pop();
            _showToasitification.showToast(
              context: context,
              toastificationType: ToastificationType.success,
              title: 'Measurement saved',
            );
          },
        ),
      ),
    );
  }
}
