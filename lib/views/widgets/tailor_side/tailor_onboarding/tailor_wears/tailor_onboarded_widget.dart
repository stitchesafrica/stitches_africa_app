// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/personal_information.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_onboarding/future_or_stream_widget/featured_works_stream_widget.dart';
import 'package:toastification/toastification.dart';

class TailorOnboardedWidget extends ConsumerWidget {
  TailorOnboardedWidget({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification showToasitification = ShowToasitification();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<TailorModel?> getTailorModel() {
    return FirebaseFirestore.instance
        .collection('tailors')
        .doc(getCurrentUserId())
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return TailorModel.fromDocument(snapshot.data()!);
      }
      return null;
    });
  }

  void tailorVerificationCheck(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    String tailorStatus = await firebaseFirestoreFunctions
        .getTailorVerificationStatus(getCurrentUserId());
    if (tailorStatus == 'approved') {
      context.pushNamed('tailorShop');
    } else if (tailorStatus == 'pending') {
      showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.info,
          title: 'Verification Pending');
    } else {
      showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: 'Verification Failed: Access denied ');
    }
    Navigator.pop(context);
  }

  Color getStatusColor(String status) {
    if (status == 'pending') {
      return Colors.amber;
    } else if (status == 'approved') {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FeaturedWorksStreamWidget(getTailorModel: getTailorModel()),
            SizedBox(
              height: 20.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    FutureBuilder(
                        future: firebaseFirestoreFunctions
                            .getTailorVerificationStatus(getCurrentUserId()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              '...',
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final status = snapshot.data!;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        color: Utilities.primaryColor,
                                        fontSize: 16.spMin,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      children: [
                                        const TextSpan(text: 'Status: '),
                                        TextSpan(
                                            text: status,
                                            style: TextStyle(
                                                fontSize: 16.spMin,
                                                fontWeight: FontWeight.w400,
                                                color: getStatusColor(status)))
                                      ]),
                                ),
                                if (status == 'denied')
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(isToUpdateInfoProvider.notifier)
                                          .state = true;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return const PersonalInformation();
                                      }));
                                    },
                                    child: Text(
                                      'Retry verification process',
                                      style: TextStyle(
                                        color: Utilities.secondaryColor,
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.spMin,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          } else {
                            return const SizedBox();
                          }
                        })
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Go to your shop',
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        tailorVerificationCheck(context);
                      },
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                      ),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
