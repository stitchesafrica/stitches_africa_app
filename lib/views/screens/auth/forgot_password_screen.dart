// ignore_for_file: use_build_context_synchronously

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_auth_service.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuthService firebaseAuthService = FirebaseAuthService();

  final ShowToasitification showToasitification = ShowToasitification();

  final TextEditingController forgotPasswordController =
      TextEditingController();

  // Error variables
  String? forgotPasswordError;

  bool _validateFields() {
    setState(() {
      forgotPasswordError = forgotPasswordController.text.isEmpty
          ? 'This field is required'
          : null;
    });
    // Return true if all fields are filled, otherwise false
    return forgotPasswordError == null;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Utilities.backgroundColor),
        );
      },
    );
  }

  Future<void> _forgotPasswordHandler() async {
    if (_validateFields()) {
      _showLoadingDialog();
      await firebaseAuthService
          .resetPassword(forgotPasswordController.text.trim());
      context.pop();
      context.pop();
      showToasitification.showToast(
        context: context,
        toastificationType: ToastificationType.success,
        title: 'Password reset link sent successfully',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
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
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.,
            children: [
              Text(
                'STITCHES AFRICA',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(
                height: 225.h,
              ),
              Text(
                'Forgot Password?',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 4.h,
              ),
              Text(
                'No worries, we\'ll send you reset instructions.',
                style: TextStyle(
                  color: Utilities.secondaryColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: forgotPasswordController,
                hintText: 'EMAIL',
                obscureText: false,
                errorText: forgotPasswordError,
              ),
              SizedBox(
                height: 25.h,
              ),
              Button(
                border: false,
                text: 'Reset Password',
                onTap: () async {
                  _forgotPasswordHandler();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
