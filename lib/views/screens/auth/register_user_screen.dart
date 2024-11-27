// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/config/providers/onboarding_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/api_service/notifications/one_signal_api.dart';
import 'package:stitches_africa/services/firebase_services/firebase_auth_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/services/hive_service/hive_service.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/password_visibility.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class RegisterUserScreen extends ConsumerStatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  ConsumerState<RegisterUserScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterUserScreen> {
  // Service Instances
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final HiveService _hiveService = HiveService();
  final OneSignalApi _oneSignalApi = OneSignalApi();

  // Controllers for form input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Error variables
  String? firstNameError;
  String? surnameError;
  String? emailError;
  String? passwordError;

  bool obscureText = true;

  bool _validateFields() {
    setState(() {
      // Reset error texts
      firstNameError =
          _firstNameController.text.isEmpty ? 'This field is required' : null;
      surnameError =
          _surnameController.text.isEmpty ? 'This field is required' : null;
      emailError =
          _emailController.text.isEmpty ? 'This field is required' : null;
      passwordError =
          _passwordController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return firstNameError == null &&
        surnameError == null &&
        emailError == null &&
        passwordError == null;
  }

  void _toggleVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  /// Register user with Firebase and store user data
  Future<void> _registerUser(String shoppingPreference) async {
    final firstName = _firstNameController.text.trim();
    final surname = _surnameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    //validate fields

    if (!_validateFields()) {
      return;
    }
    try {
      // Show loading indicator
      _showLoadingDialog();

      // Register user with Firebase Auth
      UserCredential user = await _firebaseAuthService
          .registerUserWithEmailAndPassword(email, password);

      // Save user data locally
      _hiveService.saveUserData(
        firstName: firstName,
        lastName: surname,
        shoppingPreference: shoppingPreference,
      );

      // Save user data in Firestore
      final String userId = user.user!.uid;
      await _firebaseFirestoreFunctions.addUser(email, userId, false);

      // Assign external user ID to OneSignal
      await OneSignal.login(userId);

      // Set a tag for user
      await OneSignal.User.addTags({"welcome_sent": "false"});

      //send welcome message
      String title = 'Welcome to Stitches Africa!';
      String content =
          'Explore our app and discover amazing features tailored just for you.';
      await _oneSignalApi.sendWelcomeNotifcation(title, content);

      // Navigate to the user home screen
      context.goNamed('userHome');
    } on FirebaseAuthException catch (e) {
      ShowToasitification().showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: e.code,
      );
    } finally {
      Navigator.pop(context); // Remove loading dialog
    }
  }

  /// Show a loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Utilities.backgroundColor),
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free up memory
    _emailController.dispose();
    _firstNameController.dispose();
    _passwordController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shoppingPreference = ref.watch(shoppingPreferenceProvider);

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80.h),
            Text(
              'I\'M NEW HERE',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 50.h),
            // First Name Field
            MyTextField(
              controller: _firstNameController,
              hintText: 'NAME',
              obscureText: false,
              errorText: firstNameError,
            ),
            SizedBox(height: 20.h),
            // Surname Field
            MyTextField(
              controller: _surnameController,
              hintText: 'SURNAME',
              obscureText: false,
              errorText: surnameError,
            ),
            SizedBox(height: 20.h),
            // Email Field
            MyTextField(
              controller: _emailController,
              hintText: 'EMAIL',
              obscureText: false,
              errorText: emailError,
              textType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            SizedBox(height: 20.h),
            // Password Field
            GestureDetector(
              onTap: _toggleVisibility,
              child: PasswordVisibility(
                obscureText: obscureText,
                child: MyTextField(
                  controller: _passwordController,
                  hintText: 'PASSWORD',
                  obscureText: obscureText,
                  errorText: passwordError,
                  //textType: TextInputType.visiblePassword,
                  autofillHints: const [AutofillHints.password],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Terms and Conditions
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Utilities.primaryColor,
                ),
                children: const [
                  TextSpan(text: 'By registering you are agreeing to our '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.h),
            // Register Button
            Button(
              border: false,
              text: 'Register',
              fontSize: 14.sp,
              onTap: () => _registerUser(shoppingPreference!),
            ),
            SizedBox(height: 20.h),
            Center(child: Text('OR', style: TextStyle(fontSize: 14.sp))),
            SizedBox(height: 20.h),
            // Continue with Apple
            ButtonIcon(
              text: 'Continue with Apple',
              iconPath: 'assets/icons/apple.svg',
              fontSize: 14.sp,
              border: true,
            ),
            SizedBox(height: 20.h),
            // Continue with Google
            ButtonIcon(
              text: 'Continue with Google',
              iconPath: 'assets/icons/google.svg',
              fontSize: 14.sp,
              border: true,
              onTap: () async {
                final userCredential =
                    await _firebaseAuthService.signInWithGoogle(context);

                if (userCredential != null) {
                  _showLoadingDialog();
                  _hiveService.saveUserData(
                    firstName:
                        userCredential.user!.displayName?.split(' ')[0] ?? '',
                    lastName:
                        userCredential.user!.displayName?.split(' ')[1] ?? '',
                    shoppingPreference: shoppingPreference!,
                  );
                  await _firebaseFirestoreFunctions.addUser(
                    userCredential.user!.email!,
                    userCredential.user!.uid,
                    false,
                  );
                  context.goNamed('userHome');
                  Navigator.pop(context);
                }
              },
            ),
            SizedBox(height: 50.h),
            // Navigate to login screen
            Center(
              child: GestureDetector(
                onTap: () => context.goNamed('login'),
                child: Text(
                  'ALREADY HAVE AN ACCOUNT? SIGN IN',
                  style: TextStyle(
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
