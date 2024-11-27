// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_onboarding/tailor_not_onboarded_widget.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_onboarding/tailor_onboarded_widget.dart';

class TailorBottomBar extends StatelessWidget {
  TailorBottomBar({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future:
            firebaseFirestoreFunctions.isTailorOnBoarded(getCurrentUserId()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Utilities.primaryColor));
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred'),
            );
          }
          final bool isTailorOnBoarded = snapshot.data!;
          if (isTailorOnBoarded) {
            return const TailorBottomBarOnBoardedWidget();
          } else {
            return const TailorNotOnboardedWidget();
          }
        });
  }
}
