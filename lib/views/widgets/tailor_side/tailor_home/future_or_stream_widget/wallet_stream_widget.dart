import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_home/withdrawal_screen.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:flutter/material.dart';

import 'package:stitches_africa/constants/utilities.dart';

class WalletStreamWidget extends StatelessWidget {
  final Stream<TailorModel> getTailorStream;
  const WalletStreamWidget({
    super.key,
    required this.getTailorStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getTailorStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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
          } else if (!snapshot.hasData) {
            return const Center(
                child: Text(
              'No address saved',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final tailorData = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Wallet',
                  style: TextStyle(
                      //fontFamily: 'Montserrat',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Utilities.secondaryColor)),
              Row(
                children: [
                  Text(
                    tailorData.walletBalance.toStringAsFixed(2),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    'USD',
                    style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                        color: Utilities.secondaryColor),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Button(
                  border: false,
                  text: 'Withdraw',
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return WithdrawalScreen(
                          walletBalance: tailorData.walletBalance);
                    }));
                  }),
            ],
          );
        });
  }
}
