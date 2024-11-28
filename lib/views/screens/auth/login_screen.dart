// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_auth_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/password_visibility.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Services
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  // Controllers for text input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Error variables
  String? emailError;
  String? passwordError;

  bool obscureText = true;

  bool _validateFields() {
    setState(() {
      emailError =
          _emailController.text.isEmpty ? 'This field is required' : null;
      passwordError =
          _passwordController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return emailError == null && passwordError == null;
  }

  void _toggleVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  /// Handles user login using email and password
  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!_validateFields()) {
      return;
    }

    try {
      _showLoadingDialog();

      // Authenticate user
      final user = await _firebaseAuthService.signInUserWithEmailAndPassword(
        email,
        password,
      );

      String userId = user.user!.uid;

      // Retrieve user data from Firestore and store it locally
      final userData =
          await _firebaseFirestoreFunctions.getUserDataAndStoreLocally(userId);

      // Assign external user ID to OneSignal
      OneSignal.login(userId);

      if (userData != null) {
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate based on user role
        if (userData['is_tailor'] == true) {
          context.goNamed('tailorHome');
        } else if (userData['is_general_admin'] == true) {
          context.goNamed('generalAdminHome');
        } else {
          context.goNamed('userHome');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Show error toast for FirebaseAuth errors
      ShowToasitification().showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: e.message ?? 'An error occurred',
      );
    } finally {
      // Always dismiss the loading dialog
      Navigator.pop(context);
    }
  }

  /// Show a loading dialog to indicate a pending operation
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

  /// Handles user login using Google authentication
  Future<void> _loginWithGoogle() async {
    try {
      _showLoadingDialog();

      final userCredential =
          await _firebaseAuthService.signInWithGoogle(context);

      if (userCredential != null) {
        await _firebaseFirestoreFunctions
            .getUserDataAndStoreLocally(userCredential.user!.uid);
        context.goNamed('userHome');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Google sign-in errors
      ShowToasitification().showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: e.message ?? 'Google sign-in failed',
      );
    } finally {
      // Ensure the loading dialog is dismissed
      Navigator.pop(context);
    }
  }

  void _showRegisterDialog(BuildContext context) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Register As'),
            content: const Text(
              'Please select your registration type:',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'User',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w400,
                    color: Utilities.primaryColor,
                  ),
                ),
                onPressed: () {
                  context.pushNamed('registerUser');
                  // Add registration as user logic here
                },
              ),
              CupertinoDialogAction(
                child: Text(
                  'Tailor',
                  style: TextStyle(
                    fontSize: 16.spMin,
                    fontWeight: FontWeight.w400,
                    color: Utilities.primaryColor,
                  ),
                ),
                onPressed: () {
                  context.pushNamed('registerTailor');
                  // Add registration as tailor logic here
                },
              ),
            ],
          );
        },
      );
    } else {
      // Material Dialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Register As'),
            content: const Text('Please select your registration type:'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pushNamed('registerUser');
                  // Add registration as user logic here
                },
                child: const Text('User'),
              ),
              TextButton(
                onPressed: () {
                  context.pushNamed('registerTailor');
                  // Add registration as tailor logic here
                },
                child: const Text('Tailor'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to release memory
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80.h),
            Text(
              'SIGN IN TO YOUR ACCOUNT',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 50.h),
            MyTextField(
              controller: _emailController,
              hintText: 'EMAIL',
              obscureText: false,
              errorText: emailError,
              textType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: _toggleVisibility,
              child: PasswordVisibility(
                obscureText: obscureText,
                child: MyTextField(
                  controller: _passwordController,
                  hintText: 'PASSWORD',
                  obscureText: obscureText,
                  errorText: passwordError,
                  autofillHints: const [AutofillHints.password],
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Button(
              border: false,
              text: 'Sign In',
              fontSize: 14.sp,
              onTap: _loginUser, // Trigger login
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => context.pushNamed('forgotPassword'),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.h),
            Center(
              child: Text(
                'OR',
                style: TextStyle(fontFamily: 'Montserrat', fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 20.h),
            ButtonIcon(
              text: 'Continue with Apple',
              fontSize: 14.sp,
              iconPath: 'assets/icons/apple.svg',
              border: true,
            ),
            SizedBox(height: 20.h),
            ButtonIcon(
              text: 'Continue with Google',
              fontSize: 14.sp,
              iconPath: 'assets/icons/google.svg',
              border: true,
              onTap: _loginWithGoogle, // Google sign-in
            ),
            SizedBox(height: 50.h),
            Center(
              child: GestureDetector(
                onTap: () => _showRegisterDialog(context),
                child: Text(
                  'NEW TO STITCHES AFRICA? REGISTER',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
