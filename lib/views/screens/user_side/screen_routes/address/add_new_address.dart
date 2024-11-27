// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class AddNewAddress extends StatefulWidget {
  final bool didItComeFromCheckoutScreen;
  const AddNewAddress({
    super.key,
    required this.didItComeFromCheckoutScreen,
  });

  @override
  State<AddNewAddress> createState() => _AddNewAddressState();
}

class _AddNewAddressState extends State<AddNewAddress> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final TerminalAfricaApiService _terminalAfricaApiService =
      TerminalAfricaApiService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController flatNumberController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postcodeController = TextEditingController();
  final TextEditingController dialCodeController = TextEditingController();
  final TextEditingController mobilePhoneController = TextEditingController();

  // Error variables
  String? firstNameError;
  String? surnameError;
  String? countryError;
  String? addressError;
  String? stateError;
  String? cityError;
  String? postcodeError;
  String? dialCodeError;
  String? phoneError;

  List<Map<String, dynamic>> countries = [];
  String countryCode = '';
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

  Future<void> _saveAddress(
    CollectionReference addressesSubCollection,
    CollectionReference cartCollection,
  ) async {
    if (!_validateFields()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );

    try {
      // All fields are valid, proceed with saving
      //creat packaging
      final createPackagingModel = await _terminalAfricaApiService
          .createPackaging(height: 1.0, length: 1.0, width: 1.0, weight: 0.2);
      //create pickup address
      final pickupAddressModel =
          await _terminalAfricaApiService.createPickupAddress(
        city: 'Lagos',
        countryCode: 'NG',
        email: 'stithcesafrica00@gmail.com',
        isResidential: false,
        firstName: 'Joshua',
        lastName: 'Inoma',
        line1: '13b Bishop Oluwole Street, Victoria Island',
        phone: '+2347067325701',
        state: 'Lagos',
        postalCode: '106104',
      );
      //create delivery address
      final deliveryAddressModel =
          await _terminalAfricaApiService.createDeliveryAddress(
        city: cityController.text.trim(),
        countryCode: countryCode,
        email: FirebaseAuth.instance.currentUser!.email!,
        isResidential:
            flatNumberController.text.trim().isNotEmpty ? true : false,
        firstName: firstNameController.text.trim(),
        lastName: surnameController.text.trim(),
        line1: addressController.text.trim(),
        phone:
            '${dialCodeController.text.trim()}${mobilePhoneController.text.trim()}',
        state: stateController.text.trim(),
        postalCode: postcodeController.text.trim(),
      );
      //create parcel
      //get parcel items
      final List<Map<String, dynamic>> items = await firebaseFirestoreFunctions
          .prepareParcelItemsFromCartCollection(cartCollection);
      final parcelModel = await _terminalAfricaApiService.createParcel(
        description: 'Parcel',
        packagingId: createPackagingModel.packagingId,
        items: items,
      );

      //store values
      await firebaseFirestoreFunctions.addShippingIds(getCurrentUserId(), {
        'delivery_address_id': deliveryAddressModel.addressId,
        'pickup_address_id': pickupAddressModel.addressId,
        'packaging_id': createPackagingModel.packagingId,
        'parcel_id': parcelModel.parcelId,
      });
      await firebaseFirestoreFunctions.addUserAddress(
        addressesSubCollection,
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

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is closed
      _showErrorDialog(e.toString());
    }
  }

  /// Displays an error dialog
  void _showErrorDialog(String message) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomOneButtonCupertinoDialog(
            title: 'Error',
            content: message,
            button1Text: 'OK',
            onButton1Pressed: () => context.pop(),
          );
        },
      );
    } else {
      // Material Dialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return CustomOneButtonAlertDialog(
            title: 'Error',
            content: message,
            button1Text: 'OK',
            button1BorderEnabled: false,
            onButton1Pressed: () => context.pop(),
          );
        },
      );
    }
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
    var box = Hive.box('user_preferences');
    final user = box.get('user');
    if (widget.didItComeFromCheckoutScreen) {
      firstNameController.text = user['firstName'];
      surnameController.text = user['lastName'];
    }
    final DocumentReference addressesDocRef = FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId());
    final CollectionReference addressesSubCollection =
        addressesDocRef.collection('user_addresses');

    final cartCollection = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId())
        .collection('user_cart_items');

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
                widget.didItComeFromCheckoutScreen
                    ? 'EDIT ADDRESS'
                    : 'NEW ADDRESS',
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
              widget.didItComeFromCheckoutScreen
                  ? Text(
                      'To place your order, you must first fill in your account details. You can change them in your settings at any time.',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  : const SizedBox.shrink(),
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
                    await _saveAddress(addressesSubCollection, cartCollection);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
