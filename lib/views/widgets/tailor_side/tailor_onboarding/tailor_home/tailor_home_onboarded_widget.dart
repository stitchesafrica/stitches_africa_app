import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_home/future_or_stream_widget/transaction_history_stream_widget.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_home/future_or_stream_widget/wallet_stream_widget.dart';

class TailorHomeOnboardedWidget extends StatelessWidget {
  const TailorHomeOnboardedWidget({super.key});

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<TailorModel> getTailorStream() {
    return FirebaseFirestore.instance
        .collection('tailors')
        .doc(getCurrentUserId())
        .snapshots()
        .map((snapshot) => TailorModel.fromDocument(snapshot.data()!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.h,
            ),
            WalletStreamWidget(getTailorStream: getTailorStream()),
            SizedBox(
              height: 25.h,
            ),
            SizedBox(
              width: 75.w,
              child: const Divider(
                thickness: 0.5,
                color: Utilities.secondaryColor2,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(),
                ),
                Text(
                  'View All',
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Utilities.secondaryColor),
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            SizedBox(
              width: 75.w,
              child: const Divider(
                thickness: 0.5,
                color: Utilities.secondaryColor2,
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Expanded(
                child: TransactionHistoryStreamWidget(
                    getTailorStream: getTailorStream())),
          ],
        ),
      ),
    );
  }
}
