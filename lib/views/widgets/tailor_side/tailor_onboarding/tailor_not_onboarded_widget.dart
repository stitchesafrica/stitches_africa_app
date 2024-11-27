import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';

class TailorNotOnboardedWidget extends StatelessWidget {
  const TailorNotOnboardedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              FluentSystemIcons.ic_fluent_sign_out_regular,
              color: Utilities.primaryColor,
            ),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Stitches Africa Tailor Setup!',
                textAlign: TextAlign.center,
              ),
              Text(
                'Let\'s showcase your best work and grow your business.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Utilities.secondaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Button(
                  border: false,
                  text: 'Get Started',
                  onTap: () {
                    context.pushNamed('personalInformation');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
