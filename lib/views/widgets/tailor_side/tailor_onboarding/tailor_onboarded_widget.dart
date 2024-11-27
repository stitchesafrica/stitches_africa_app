import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/tailor_side/main/my_wears.dart';
import 'package:stitches_africa/views/screens/tailor_side/main/tailor_home.dart';
import 'package:stitches_africa/views/screens/tailor_side/main/tailor_profile.dart';

class TailorBottomBarOnBoardedWidget extends ConsumerStatefulWidget {
  const TailorBottomBarOnBoardedWidget({super.key});

  @override
  ConsumerState<TailorBottomBarOnBoardedWidget> createState() =>
      _TailorOnboardedWidgetState();
}

class _TailorOnboardedWidgetState extends ConsumerState<TailorBottomBarOnBoardedWidget> {
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  int _currentIndex = 0;

  List<Widget> screenPages = [TailorHome(), MyWorks(), TailorProfile()];

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
        title: _currentIndex == 0
            ? Text(
                'STITCHES AFRICA',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
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

              await _firebaseFirestoreFunctions.refreshTailorOrders(
                  ref, getCurrentUserId());

              Navigator.pop(context);
              context.pushNamed('tailorOrdersScreen');
            },
            child: SvgPicture.asset(
              'assets/icons/package.svg',
              height: 22.h,
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: screenPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          enableFeedback: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Utilities.backgroundColor,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          elevation: 0,
          selectedItemColor: Utilities.primaryColor,
          unselectedItemColor: Utilities.secondaryColor3,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11.sp,
          unselectedFontSize: 11.sp,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              label: 'Home',
              icon: SvgPicture.asset(
                'assets/icons/logo2.svg',
                height: 22.h,
                color: _currentIndex == 0
                    ? Utilities.primaryColor
                    : Utilities.secondaryColor3,
              ),
            ),
            BottomNavigationBarItem(
              label: 'My Wears',
              icon: SvgPicture.asset(
                'assets/icons/sewing-needle.svg',
                height: 22.h,
                color: _currentIndex == 1
                    ? Utilities.primaryColor
                    : Utilities.secondaryColor3,
              ),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: SvgPicture.asset(
                'assets/icons/user-account-profile.svg',
                height: 22.h,
                color: _currentIndex == 2
                    ? Utilities.primaryColor
                    : Utilities.secondaryColor3,
              ),
            ),
          ]),
    );
  }
}
