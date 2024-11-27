// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';

class TotalPriceFutureWidget extends StatelessWidget {
  final CollectionReference cartSubCollection;
  TotalPriceFutureWidget({super.key, required this.cartSubCollection});
  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.fromFuture(
            firebaseFirestoreFunctions.getTotalPrice(cartSubCollection)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Utilities.secondaryColor2,
              highlightColor: Utilities.backgroundColor,
              child: Container(
                height: 20.h,
                width: 50.w,
                color: Utilities.secondaryColor,
              ),
            );
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
          } else if (!snapshot.hasData) {
            return Text(
              '0.0 USD',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            );
          }
          double totalPrice = snapshot.data!;
          return Text(
            '$totalPrice USD',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          );
        });
  }
}
