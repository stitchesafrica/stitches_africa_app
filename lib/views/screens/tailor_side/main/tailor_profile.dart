// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/profile/brand_profile.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/profile_widget.dart';

class TailorProfile extends StatelessWidget {
  TailorProfile({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Future<TailorModel?> getTailorModel() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('tailors')
          .doc(getCurrentUserId())
          .get();

      if (snapshot.exists) {
        return TailorModel.fromDocument(
            snapshot.data() as Map<String, dynamic>);
      }
      return null; // Return null if the document doesn't exist
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching tailor model: $e');
      }
      return null; // Handle any errors by returning null or an appropriate error response
    }
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('user_preferences');
    final user = box.get('user');
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    user['firstName'].toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 24.sp,
                      //letterSpacing: 1,
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
                    text: 'Brand Profile',
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.backgroundColor));
                          });
                      final tailorModel = await getTailorModel();
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BrandProfile(tailorModel: tailorModel!);
                      }));
                    },
                  ),
                ],
              ),
              Button(
                  border: true,
                  text: 'Sign Out',
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    //hiveService.clearUserSession();
                    context.goNamed('onboarding1');
                  })
            ],
          ),
        ),
      ),
    );
  }
}
