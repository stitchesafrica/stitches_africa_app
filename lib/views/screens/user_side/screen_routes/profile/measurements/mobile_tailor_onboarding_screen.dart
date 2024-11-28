// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/measurement/person_model.dart';
import 'package:stitches_africa/services/api_service/measurements/measurement_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/onboarding/measurement/email_address_screen.dart';
import 'package:stitches_africa/views/screens/onboarding/measurement/gender_screen.dart';
import 'package:stitches_africa/views/screens/onboarding/measurement/height_screen.dart';
import 'package:stitches_africa/views/screens/onboarding/measurement/weight_screen.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

class MobileTailorOnboardingScreen extends ConsumerWidget {
  MobileTailorOnboardingScreen({super.key});

  final PageController _pageController = PageController();
  final MeasurementApiService _measurementApiService = MeasurementApiService();
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification _showToasitification = ShowToasitification();
  final List<Widget> pageScreens = [
    EmailAddressScreen(),
    const GenderScreen(),
    const HeightScreen(),
    const WeightScreen(),
  ];

  Widget _firstPageButton(
      BuildContext context, WidgetRef ref, bool isAccepted) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                ref.read(isAcceptedProvider.notifier).state = !isAccepted;
              },
              child: Container(
                alignment: Alignment.center,
                height: 14.h,
                width: 14.w,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: isAccepted
                        ? Utilities.primaryColor
                        : Utilities.secondaryColor,
                  ),
                  borderRadius: BorderRadius.circular(2.r),
                  color:
                      isAccepted ? Utilities.primaryColor : Colors.transparent,
                ),
                child: isAccepted
                    ? SvgPicture.asset(
                        'assets/icons/check.svg',
                        color: Utilities.backgroundColor,
                      )
                    : null,
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(
                    'https://www.termsfeed.com/live/6adbb14a-8c18-48c6-941f-f2507251443e'));
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w400,
                    color: Utilities.secondaryColor,
                  ),
                  children: const [
                    TextSpan(
                      text: 'I accept the ',
                    ),
                    TextSpan(
                      text: 'Terms of use ',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Utilities.primaryColor,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'and ',
                    ),
                    TextSpan(
                      text: 'Privacy policy',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Utilities.primaryColor,
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        Button(
            border: false,
            text: 'Next',
            onTap: () {
              if (isAccepted) {
                _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              } else {
                _showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.error,
                    title: 'Accept the terms and privacy to continue');
              }
            }),
      ],
    );
  }

  Widget _defaultButton(BuildContext context, WidgetRef ref, int pageIndex) {
    return Button(
        border: false,
        text: pageIndex == pageScreens.length - 1 ? 'Save' : 'Next',
        onTap: () {
          // on last page
          if (pageIndex == pageScreens.length - 1) {
            _showConfirmationDialog(context, ref);
          } else {
            _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn);
          }
        });
  }

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  /// Displays a loading dialog
  void _showLoadingDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, WidgetRef ref) {
    final String gender = ref.read(genderProvider);
    final int height = ref.read(heightProvider);
    final double weight = ref.read(weightProvider).toDouble();
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Confirm Your Details',
            content: 'Please review the details below:\n\n'
                'Gender: $gender\n'
                'Height: $height cm\n'
                'Weight: $weight kg',
            button1Text: 'Edit',
            button2Text: 'Confirm',
            onButton1Pressed: () => context.pop(),
            onButton2Pressed: () async {
              context.pop();
              await _saveHandler(context, ref);
            },
          );
        },
      );
    } else {
      // Material AlertDialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Confirm Your Details',
            content: 'Please review the details below:\n\n'
                'Gender: $gender\n'
                'Height: $height cm\n'
                'Weight: $weight kg',
            button1Text: 'Edit',
            button2Text: 'Confirm',
            button1BorderEnabled: true,
            button2BorderEnabled: false,
            onButton1Pressed: () => context.pop(),
            onButton2Pressed: () async {
              context.pop();
              await _saveHandler(context, ref);
            },
          );
        },
      );
    }
  }

  Future<void> _saveHandler(BuildContext context, WidgetRef ref) async {
    final personModel = await _createPersonModel(context, ref);
    await _saveToDb(context, personModel);

    // navigate to upload images
    context.pushNamed('updateUserMeasurementScreen');
  }

  Future<PersonModel> _createPersonModel(
      BuildContext context, WidgetRef ref) async {
    final String gender = ref.read(genderProvider);
    final int height = ref.read(heightProvider);
    final double weight = ref.read(weightProvider).toDouble();

    _showLoadingDialog(context, 'Creating profile...');
    final personModel = await _measurementApiService.createPerson(
        gender: gender, height: height, weight: weight);
    context.pop();
    return personModel;
  }

  Future<void> _saveToDb(BuildContext context, PersonModel personModel) async {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection('users_measurements');
    _showLoadingDialog(context, 'Creating profile...');
    await _firebaseFirestoreFunctions.addUserMeasurementData(
        collection,
        _getCurrentUserId(),
        personModel.id,
        personModel.userId,
        personModel.gender,
        personModel.height,
        personModel.weight);
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAccepted = ref.watch(isAcceptedProvider);
    final pageIndex = ref.watch(pageIndexProvider);
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            SizedBox(
              height: 75.h,
            ),
            Row(
              children: [
                Expanded(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: pageScreens.length,
                    effect: ExpandingDotsEffect(
                      expansionFactor: 7.w,
                      dotWidth: 11.w,
                      dotHeight: 5.h,
                      radius: 0.r,
                      activeDotColor: Utilities.primaryColor,
                      dotColor: Utilities.secondaryColor3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Transform.flip(
                    flipX: true,
                    child: const Icon(
                      FluentSystemIcons.ic_fluent_dismiss_filled,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                // physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(pageIndexProvider.notifier).state = index;
                },
                itemCount: pageScreens.length,
                itemBuilder: (context, index) {
                  return pageScreens[index];
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          height: pageIndex == 0 ? 70.h : 40.h,
          elevation: 0,
          color: Utilities.backgroundColor,
          padding: EdgeInsets.zero,
          child: pageIndex == 0
              ? _firstPageButton(context, ref, isAccepted)
              : _defaultButton(context, ref, pageIndex)),
    );
  }
}
