import 'dart:convert';

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';

class ContactInformationScreen extends ConsumerStatefulWidget {
  const ContactInformationScreen({super.key});

  @override
  ConsumerState<ContactInformationScreen> createState() =>
      _ContactInformationScreenState();
}

class _ContactInformationScreenState
    extends ConsumerState<ContactInformationScreen> {
  ShowToasitification showToasitification = ShowToasitification();
  final TextEditingController tailorEmailAddressController =
      TextEditingController();
  final TextEditingController dialCodeController = TextEditingController();
  final TextEditingController mobilePhoneController = TextEditingController();

  // Error variables
  String? tailorEmailAddressError;
  String? dialCodeError;
  String? mobilePhoneError;

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
              height: 200,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.h,
                scrollController: FixedExtentScrollController(
                    initialItem:
                        countries.first['name'].indexOf(selectedCountry)),
                onSelectedItemChanged: (index) {
                  setState(() {
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
      tailorEmailAddressError = tailorEmailAddressController.text.isEmpty
          ? 'This field is required'
          : null;
      dialCodeError =
          dialCodeController.text.isEmpty ? 'This field is required' : null;
      mobilePhoneError =
          mobilePhoneController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return tailorEmailAddressError == null &&
        dialCodeError == null &&
        mobilePhoneError == null;
  }

  @override
  void initState() {
    super.initState();
    loadCountriesData();
  }

  @override
  Widget build(BuildContext context) {
    String tailorEmailAddress = ref.watch(tailorEmailAddressProvider);
    String dialCode = ref.watch(tailorDialCodeProvider);
    String mobilePhone = ref.watch(tailorPhoneNumberProvider);

    if (tailorEmailAddress != '') {
      tailorEmailAddressController.text = tailorEmailAddress;
      dialCodeController.text = dialCode;
      mobilePhoneController.text = mobilePhone;
    }

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
                'CONTACT INFORMATION',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  //letterSpacing: ,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Provide your contact details',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: tailorEmailAddressController,
                hintText: 'EMAIL ADDRESS',
                obscureText: false,
                errorText: tailorEmailAddressError,
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _showCountryPicker,
                    child: AbsorbPointer(
                      child: SizedBox(
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
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: MyTextField(
                      controller: mobilePhoneController,
                      hintText: 'MOBILE PHONE',
                      obscureText: false,
                      errorText: mobilePhoneError,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.h,
              ),
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
            onTap: () {
              if (_validateFields()) {
                ref.read(tailorEmailAddressProvider.notifier).state =
                    tailorEmailAddressController.text;
                ref.read(tailorDialCodeProvider.notifier).state =
                    dialCodeController.text;
                ref.read(tailorPhoneNumberProvider.notifier).state =
                    mobilePhoneController.text;
                context.pushNamed('featuredWorks');
              }
            }),
      ),
    );
  }
}
