import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/upload_media_widget.dart';
import 'package:stitches_africa/views/tailor_bottom_bar.dart';

class FeaturedWorksScreen extends ConsumerWidget {
  FeaturedWorksScreen({super.key});
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        padding: EdgeInsets.symmetric(
          horizontal: 15.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              'FEATURED WORKS',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                //letterSpacing: ,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Showcase your best works to highlight your craft.',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UploadMediaWidget(
                    imageHeight: 400.h,
                    uploadMultipleImages: true,
                    text1: 'Upload your best works or ',
                    text2: 'provide URLs',
                    text3: 'Supported format: .png, .jpg, .jpeg')
              ],
            ))
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
            border: false,
            text: 'Continue',
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              String fullName = ref.read(fullNameProvider);
              String dob =
                  '${ref.read(dayProvider)}/${ref.read(monthProvider)}/${ref.read(yearProvider)}';
              String faceImage = ref.read(faceImageProvider);
              String identityImage = ref.read(identityProvider);
              String streetAddress = ref.read(streetAddressProvider);
              String city = ref.read(cityProvider);
              String state = ref.read(stateProvider);
              String postalcode = ref.read(postalCodeProvider);
              String country = ref.read(countryProvider);
              String addressImage = ref.read(addressImageProvider);
              String tailorBrandName = ref.read(tailorBrandNameProvider);
              String tailorTagline = ref.read(tailorTaglineProvider);
              String tailorLogo = ref.read(tailorLogoProvider);
              String tailorEmailAddress = ref.read(tailorEmailAddressProvider);
              String dialCode = ref.read(tailorDialCodeProvider);
              String phoneNumber = ref.read(tailorPhoneNumberProvider);
              List<String> tailorFeaturedWorks = ref.read(mediaPathsProvider);
              await firebaseFirestoreFunctions
                  .createTailorData(
                getCurrentUserId(),
                fullName,
                dob,
                faceImage,
                identityImage,
                streetAddress,
                city,
                state,
                postalcode,
                country,
                addressImage,
                tailorBrandName,
                tailorTagline,
                tailorLogo,
                tailorEmailAddress,
                dialCode,
                phoneNumber,
                tailorFeaturedWorks,
              )
                  .then((_) {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TailorBottomBar();
                }));
              });
            }),
      ),
    );
  }
}
