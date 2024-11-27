import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';

class DetailsAndSecurityScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const DetailsAndSecurityScreen({super.key, required this.data});

  @override
  ConsumerState<DetailsAndSecurityScreen> createState() =>
      _DetailsAndSecurityScreenState();
}

class _DetailsAndSecurityScreenState
    extends ConsumerState<DetailsAndSecurityScreen> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification showToasitification = ShowToasitification();
  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController lastNameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();

  // Error variables
  String? firstNameError;
  String? lastError;
  String? emailError;

  bool _validateFields() {
    setState(() {
      // Reset error texts
      firstNameError =
          firstNameController.text.isEmpty ? 'This field is required' : null;
      lastError =
          lastNameController.text.isEmpty ? 'This field is required' : null;
      emailError =
          emailController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return firstNameError == null && lastError == null && emailError == null;
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  void initState() {
    super.initState();

    firstNameController.text = widget.data['first_name'];
    lastNameController.text = widget.data['last_name'];
    emailController.text = widget.data['email'];
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
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
        title: Text(
          'Details and Security',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              await firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);
              Navigator.pop(context);
              context.pushNamed('shoppingScreen');
            },
            child: SvgPicture.asset(
              'assets/icons/bag.svg',
              height: 22.h,
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                'MY DETAILS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  // letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: firstNameController,
                hintText: 'FIRST NAME',
                obscureText: false,
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: lastNameController,
                hintText: 'LAST NAME',
                obscureText: false,
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: emailController,
                readOnly: true,
                hintText: 'EMAIL',
                obscureText: false,
              ),
              SizedBox(
                height: 50.h,
              ),
              Text(
                'Delete Account',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'You can request for your account or your personal deetails to be deleted at any time. By doinng so you will no logner be able to access your STITCHES AFRICA account. Go to our Privacy Policy to learn more.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Button(
                border: true,
                text: 'Privacy Policy',
                onTap: () {},
              ),
              SizedBox(
                height: 20.h,
              ),
              Button(
                border: true,
                text: 'Request To Delete',
                onTap: () {},
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
            border: false,
            text: 'Update Details',
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              await firebaseFirestoreFunctions.updateUserDetails(
                  getCurrentUserId(),
                  firstNameController.text.trim(),
                  lastNameController.text.trim());

              Navigator.pop(context);
              Navigator.pop(context);
            }),
      ),
    );
  }
}
