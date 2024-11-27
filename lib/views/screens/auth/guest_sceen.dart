// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_auth_service.dart';
import 'package:stitches_africa/services/hive_service/hive_service.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';
import 'package:stitches_africa/views/components/glassbox.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class GuestPage extends ConsumerStatefulWidget {
  const GuestPage({super.key});

  @override
  ConsumerState<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends ConsumerState<GuestPage> {
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  HiveService hiveService = HiveService();

  void signInAnonymously() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          });
      await firebaseAuthService.signInAnonymously();
      await Future.delayed(const Duration(milliseconds: 500));
      context.goNamed('userHome');
    } on FirebaseAuthException catch (e) {
      ShowToasitification().showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: e.code);
    }
  }

  void _showRegisterDialog(BuildContext context) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Register As',
            content: 'Please select your registration type:',
            button1Text: 'User',
            button2Text: 'Tailor',
            onButton1Pressed: () => context.pushNamed('registerUser'),
            onButton2Pressed: () => context.pushNamed('registerTailor'),
          );
        },
      );
    } else {
      // Material Dialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Register As',
            content: 'Please select your registration type:',
            button1Text: 'User',
            button2Text: 'Tailor',
            button1BorderEnabled: true,
            button2BorderEnabled: true,
            onButton1Pressed: () => context.pushNamed('registerUser'),
            onButton2Pressed: () => context.pushNamed('registerTailor'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 80.h, left: 55.w),
            height: 841.h,
            width: 631.w,
            decoration: const BoxDecoration(
              //color: Colors.red,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/guest_2.png'),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: SizedBox(
              height: 250.h,
              width: 400.w,
              child: GlassBox(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25.h,
                    ),
                    Text(
                      'LET\'S TAILOR IT\nTO YOU',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    const Text(
                      'Sign in for a bespoke shopping experience.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: Button(
                              fontSize: 14.sp,
                              border: true,
                              text: 'Register',
                              onTap: () {
                                _showRegisterDialog(context);
                              }),
                        ),
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: Button(
                              fontSize: 14.sp,
                              border: false,
                              text: 'Sign in',
                              onTap: () {
                                context.pushNamed('login');
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              )),
            ),
          ),
          // Positioned(
          //   bottom: 740.h,
          //   right: 240.w,
          //   child: GestureDetector(
          //     onTap: () {
          //       signInAnonymously();
          //     },
          //     child: Text(
          //         'SIGN IN AS GUEST',
          //         style: TextStyle(
          //           fontFamily: 'Montserrat',
          //           fontSize: 14.sp,
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //   ),
          // )
        ],
      ),
    );
  }
}
