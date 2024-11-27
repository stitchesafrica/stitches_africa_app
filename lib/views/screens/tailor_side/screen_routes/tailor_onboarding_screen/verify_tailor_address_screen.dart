// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/components/upload_media_widget.dart';
import 'package:stitches_africa/views/tailor_bottom_bar.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';
import 'package:toastification/toastification.dart';

class VerifyTailorAddressScreen extends ConsumerStatefulWidget {
  const VerifyTailorAddressScreen({
    super.key,
  });

  @override
  ConsumerState<VerifyTailorAddressScreen> createState() =>
      _AddNewAddressState();
}

class _AddNewAddressState extends ConsumerState<VerifyTailorAddressScreen> {
  final ShowToasitification showToasitification = ShowToasitification();
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();

  // Error variables

  String? countryError;
  String? addressError;
  String? stateError;
  String? cityError;
  String? postcodeError;

  List<Map<String, dynamic>> countries = [];
  String selectedCountry = 'Select a country';

  Future<List<Map<String, dynamic>>> loadCountries() async {
    String data = await rootBundle.loadString('assets/json/country_code.json');
    List<dynamic> jsonResult = json.decode(data);
    return jsonResult.cast<Map<String, dynamic>>();
  }

  Future<void> loadCountriesData() async {
    countries = await loadCountries();
    setState(() {}); // Update the UI once countries are loaded
  }

  void _showCountryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        color: Utilities.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 190.h,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.h,
                scrollController: FixedExtentScrollController(
                    initialItem:
                        countries.first['name'].indexOf(selectedCountry)),
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedCountry = countries[index]['name'];
                    countryController.text = selectedCountry;
                  });
                },
                children:
                    countries.map((country) => Text(country['name'])).toList(),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Select',
                style: TextStyle(
                  color: Utilities.primaryColor,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ),
      ),
    );
  }

  bool _validateFields() {
    setState(() {
      // Reset error texts

      countryError =
          countryController.text.isEmpty ? 'This field is required' : null;
      addressError =
          addressController.text.isEmpty ? 'This field is required' : null;
      stateError =
          stateController.text.isEmpty ? 'This field is required' : null;
      cityError = cityController.text.isEmpty ? 'This field is required' : null;
      postcodeError =
          postcodeController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return countryError == null &&
        addressError == null &&
        stateError == null &&
        cityError == null &&
        postcodeError == null;
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  void initState() {
    super.initState();
    loadCountriesData();
  }

  @override
  Widget build(BuildContext context) {
    String streetAddress = ref.watch(streetAddressProvider);
    String city = ref.watch(cityProvider);
    String state = ref.watch(stateProvider);
    String postcode = ref.watch(postalCodeProvider);
    String country = ref.watch(countryProvider);
    String addressImage = ref.watch(addressImageProvider);

    if (streetAddress != '') {
      addressController.text = streetAddress;
      cityController.text = city;
      stateController.text = state;
      postcodeController.text = postcode;
      countryController.text = country;
    }

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADDRESS INFORMATION',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.sp,
                  // letterSpacing: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'Please provide your current residential address and upload a document as proof of address.',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              MyTextField(
                controller: addressController,
                hintText: 'STREET ADDRESS',
                obscureText: false,
                errorText: addressError,
                // autofillHints: const [AutofillHints.streetAddressLevel1],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: cityController,
                hintText: 'CITY',
                obscureText: false,
                errorText: cityError,
                autofillHints: const [AutofillHints.addressCity],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: stateController,
                hintText: 'STATE OR PROVIDENCE',
                obscureText: false,
                errorText: stateError,
                autofillHints: const [AutofillHints.addressState],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: postcodeController,
                hintText: 'POST CODE',
                obscureText: false,
                errorText: postcodeError,
                autofillHints: const [AutofillHints.postalCode],
              ),
              SizedBox(height: 20.h),
              GestureDetector(
                onTap: _showCountryPicker,
                child: AbsorbPointer(
                  child: MyTextField(
                    controller: countryController,
                    hintText: 'COUNTRY',
                    obscureText: false,
                    errorText: countryError,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(height: 20.h),
              UploadMediaWidget(
                saveImage: (imageUrl) {
                  ref.read(addressImageProvider.notifier).state = imageUrl!;
                },
                imageHeight: 100.h,
                uploadMultipleImages: false,
                text1: 'Upload a clear image of your proof of address.',
                text3:
                    '(Utility bills, bank statements)\nSupported format: .png, .jpg, .jpeg',
              ),
              if (addressImage != '')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imageUrl: addressImage,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: addressImage,
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CachedNetworkImage(
                              imageUrl: addressImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'view uploaded image',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Utilities.secondaryColor3,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              SizedBox(height: 30.h),
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
            text: 'Continue',
            onTap: () async {
              if (_validateFields() && addressImage != '') {
                ref.read(streetAddressProvider.notifier).state =
                    addressController.text;
                ref.read(cityProvider.notifier).state = cityController.text;
                ref.read(stateProvider.notifier).state = stateController.text;
                ref.read(postalCodeProvider.notifier).state =
                    postcodeController.text;
                ref.read(countryProvider.notifier).state =
                    countryController.text;

                if (ref.read(isToUpdateInfoProvider)) {
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
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Utilities.backgroundColor));
                      });
                  await firebaseFirestoreFunctions.updateTailorKYCDetails(
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
                      addressImage);
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TailorBottomBar();
                  }));
                } else {
                  context.pushNamed('profileSetup');
                }
              } else if (_validateFields() && addressImage == '') {
                showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.error,
                    title: 'Logo not uploaded');
              }
            }),
      ),
    );
  }
}
