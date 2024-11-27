import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';

class UserNotScannedWidget extends StatelessWidget {
  const UserNotScannedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      // appBar: AppBar(
      //   leading: GestureDetector(
      //     onTap: () {
      //       context.pop();
      //     },
      //     child: Transform.flip(
      //       flipX: true,
      //       child: const Icon(
      //         FluentSystemIcons.ic_fluent_dismiss_filled,
      //       ),
      //     ),
      //   ),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SizedBox(
          //   height: 50.h,
          // ),
          SizedBox(
            height: 350.h,
            child: Image.asset(
              'assets/images/scan_image.png',
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              'FORGET ABOUT MEASURING TAPE OR APPOINTMENTS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              'No quiz, no measuring tape, no return hassle - in under a minute!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Utilities.secondaryColor),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
            border: false,
            text: 'Continue',
            onTap: () {
              context.pushNamed('mobileTailorOnBoardingScreen');
            }),
      ),
    );
  }
}
