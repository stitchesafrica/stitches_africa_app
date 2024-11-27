import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/details_and_security_screen.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/profile_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/shopping_preference_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<AddressModel>> getUserAddresses() {
    return FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId())
        .collection('user_addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromDocument(doc.data()))
            .toList());
  }

  void launchEmail(
    String email,
  ) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      throw 'Could not launch $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    // HiveService hiveService = HiveService();
    var box = Hive.box('user_preferences');
    final user = box.get('user');
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                user['firstName'].toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 40.h,
              ),
              Text(
                'My account',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              ProfileWidget(
                text: 'Measurements',
                onTap: () => context.pushNamed('measurementsScreen'),
              ),
              ProfileWidget(
                text: 'Orders and returns',
                onTap: () => context.pushNamed('userOrdersScreen'),
              ),
              ProfileWidget(
                  text: 'Details and security',
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        });
                    final data = await firebaseFirestoreFunctions
                        .getUserDataAndStoreLocally(getCurrentUserId());
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return DetailsAndSecurityScreen(data: data!);
                    }));
                  }),
              ProfileWidget(
                text: 'Address book',
                getUserAddressesStream: getUserAddresses(),
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                'My shopping preferences',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              const ShoppingPreferenceWidget(),
              SizedBox(
                height: 30.h,
              ),
              Text(
                'Support',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              const ProfileWidget(
                text: 'About STITCHES AFRICA',
              ),
              const ProfileWidget(
                text: 'Terms & conditions',
              ),
              const ProfileWidget(
                text: 'Privacy policy',
              ),
              const ProfileWidget(
                text: 'FAQs & guides',
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'Get in touch with our global customer service team.',
                style:
                    TextStyle(fontSize: 16.spMin, fontWeight: FontWeight.w400),
              ),
              SizedBox(
                height: 30.h,
              ),
              Button(
                  border: true,
                  text: 'Contact us',
                  onTap: () {
                    launchEmail('stithcesafrica00@gmail.com');
                  }),
              SizedBox(
                height: 50.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not ${user['firstName']}?',
                    style: TextStyle(
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 225.w,
                    child: Button(
                        border: true,
                        text: 'Sign Out',
                        onTap: () {
                          FirebaseAuth.instance.signOut();
                          //hiveService.clearUserSession();
                          context.goNamed('onboarding1');
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
