// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/measurements/update_user_measurement_screen.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/measurements/user_not_scanned_widget.dart';

class MobileTailorMeasurementScreen extends StatelessWidget {
  MobileTailorMeasurementScreen({super.key});

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    return const UserNotScannedWidget();
  }
}
