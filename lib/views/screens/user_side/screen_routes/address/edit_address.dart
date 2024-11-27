// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/shopping_bag/checkout_screen.dart';

class EditAddressScreen extends StatefulWidget {
  final AddressModel addressModelData;
  final String docId;
  const EditAddressScreen({
    super.key,
    required this.addressModelData,
    required this.docId,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final TerminalAfricaApiService _terminalAfricaApiService =
      TerminalAfricaApiService();
  ShowToasitification showToasitification = ShowToasitification();

  late TextEditingController firstNameController = TextEditingController();
  late TextEditingController surnameController = TextEditingController();
  late TextEditingController countryController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController flatNumberController = TextEditingController();
  late TextEditingController stateController = TextEditingController();
  late TextEditingController cityController = TextEditingController();
  late TextEditingController postcodeController = TextEditingController();
  late TextEditingController dialCodeController = TextEditingController();
  late TextEditingController mobilePhoneController = TextEditingController();

  // Error variables
  String? firstNameError;
  String? surnameError;
  String? countryError;
  String? addressError;
  String? flatNumberError;
  String? stateError;
  String? cityError;
  String? postcodeError;
  String? dialCodeError;
  String? phoneError;

  List<Map<String, dynamic>> countries = [];
  String countryCode = "";
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
              height: 200,
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
                    countryCode = countries[index]['code'];
                    dialCodeController.text = countries[index]['dial_code'];
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
      firstNameError =
          firstNameController.text.isEmpty ? 'This field is required' : null;
      surnameError =
          surnameController.text.isEmpty ? 'This field is required' : null;
      countryError =
          countryController.text.isEmpty ? 'This field is required' : null;
      addressError =
          addressController.text.isEmpty ? 'This field is required' : null;
      flatNumberError =
          flatNumberController.text.isEmpty ? 'This field is required' : null;
      stateError =
          stateController.text.isEmpty ? 'This field is required' : null;
      cityError = cityController.text.isEmpty ? 'This field is required' : null;
      postcodeError =
          postcodeController.text.isEmpty ? 'This field is required' : null;
      dialCodeError =
          dialCodeController.text.isEmpty ? 'This field is required' : null;
      phoneError =
          mobilePhoneController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return firstNameError == null &&
        surnameError == null &&
        countryError == null &&
        addressError == null &&
        stateError == null &&
        cityError == null &&
        postcodeError == null &&
        phoneError == null;
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
    firstNameController.text = widget.addressModelData.firstName;
    surnameController.text = widget.addressModelData.lastName;
    countryController.text = widget.addressModelData.country;
    countryCode = widget.addressModelData.countryCode;
    addressController.text = widget.addressModelData.streetAddress;
    flatNumberController.text = widget.addressModelData.flatNumber ?? '';
    stateController.text = widget.addressModelData.state;
    cityController.text = widget.addressModelData.city;
    postcodeController.text = widget.addressModelData.postcode;
    dialCodeController.text = widget.addressModelData.dialCode;
    mobilePhoneController.text = widget.addressModelData.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box('user_preferences');
    final user = box.get('user');
    firstNameController.text = user['firstName'];
    surnameController.text = user['lastName'];

    final DocumentReference addressesDocRef = FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId());
    final CollectionReference addressesSubCollection =
        addressesDocRef.collection('user_addresses');

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
                'EDIT ADDRESS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Text(
                'To place your order, you must first fill in your account details. You can change them in your settings at any time.',
                style: TextStyle(
                  fontSize: 14.spMin,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              MyTextField(
                controller: firstNameController,
                hintText: 'NAME',
                obscureText: false,
                errorText: firstNameError,
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: surnameController,
                hintText: 'SURNAME',
                obscureText: false,
                errorText: surnameError,
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
              MyTextField(
                controller: addressController,
                hintText: 'ADDRESS',
                obscureText: false,
                errorText: addressError,
                // autofillHints: const [AutofillHints.streetAddressLevel1],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: flatNumberController,
                hintText: 'FLAT NUMBER',
                obscureText: false,
                errorText: flatNumberError,
                //autofillHints: const [AutofillHints.add],
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
                controller: cityController,
                hintText: 'CITY',
                obscureText: false,
                errorText: cityError,
                autofillHints: const [AutofillHints.addressCity],
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
              Row(
                children: [
                  SizedBox(
                    width: 60.w,
                    child: MyTextField(
                      controller: dialCodeController,
                      hintText: 'PREFIX',
                      obscureText: false,
                      errorText: dialCodeError,
                      autofillHints: const [
                        AutofillHints.telephoneNumberLocalPrefix
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: MyTextField(
                      controller: mobilePhoneController,
                      hintText: 'MOBILE PHONE',
                      obscureText: false,
                      errorText: phoneError,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Button(
                  border: true,
                  text: 'Save',
                  onTap: () async {
                    if (_validateFields()) {
                      //first get the doc id
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.backgroundColor));
                          });
                      await firebaseFirestoreFunctions.updateUserAddress(
                        addressesSubCollection,
                        widget.docId,
                        firstNameController.text.trim(),
                        surnameController.text.trim(),
                        countryController.text.trim(),
                        countryCode,
                        addressController.text.trim(),
                        flatNumberController.text.trim(),
                        stateController.text.trim(),
                        cityController.text.trim(),
                        postcodeController.text.trim(),
                        dialCodeController.text.trim(),
                        mobilePhoneController.text.trim(),
                      );

                      context.pop();
                      context.pop();
                      context.pop();
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
