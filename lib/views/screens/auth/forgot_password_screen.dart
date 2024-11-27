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

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  final ShowToasitification showToasitification = ShowToasitification();
  final TextEditingController forgotPasswordController =
      TextEditingController();

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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forgot Password?',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24.sp,
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
              ),
              SizedBox(
                height: 25.h,
              ),
              Button(
                  border: false,
                  text: 'Reset Password',
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        });
                    await firebaseAuthService
                        .resetPassword(forgotPasswordController.text.trim());
                    Navigator.pop(context);
                    showToasitification.showToast(
                        context: context,
                        toastificationType: ToastificationType.success,
                        title: 'Password reset link sent successfully');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
