// ignore_for_file: use_build_context_synchronously

import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class SeeUserAddress extends StatefulWidget {
  final Map<String, dynamic> userAddressData;

  const SeeUserAddress({
    super.key,
    required this.userAddressData,
  });

  @override
  State<SeeUserAddress> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<SeeUserAddress> {
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

  @override
  void initState() {
    super.initState();

    firstNameController.text = widget.userAddressData['first_name'];
    surnameController.text = widget.userAddressData['last_name'];
    countryController.text = widget.userAddressData['country'];
    addressController.text = widget.userAddressData['street_address'];
    flatNumberController.text = widget.userAddressData['flat_number'] ?? '';
    stateController.text = widget.userAddressData['state'];
    cityController.text = widget.userAddressData['city'];
    postcodeController.text = widget.userAddressData['post_code'];
    dialCodeController.text = widget.userAddressData['dial_code'];
    mobilePhoneController.text = widget.userAddressData['phone_number'];
  }

  @override
  Widget build(BuildContext context) {
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
                'USER ADDRESS',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16.sp,
                  letterSpacing: 1,
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
                readOnly: true,
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: surnameController,
                hintText: 'SURNAME',
                obscureText: false,
                readOnly: true,
              ),
              SizedBox(height: 20.h),
              AbsorbPointer(
                child: MyTextField(
                  controller: countryController,
                  hintText: 'COUNTRY',
                  obscureText: false,
                  readOnly: true,
                ),
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: addressController,
                hintText: 'ADDRESS',
                obscureText: false,
                readOnly: true,
                // autofillHints: const [AutofillHints.streetAddressLevel1],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: flatNumberController,
                hintText: 'FLAT NUMBER',
                obscureText: false,
                readOnly: true,
                //autofillHints: const [AutofillHints.add],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: stateController,
                hintText: 'STATE OR PROVIDENCE',
                obscureText: false,
                readOnly: true,
                autofillHints: const [AutofillHints.addressState],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: cityController,
                hintText: 'CITY',
                obscureText: false,
                readOnly: true,
                autofillHints: const [AutofillHints.addressCity],
              ),
              SizedBox(height: 20.h),
              MyTextField(
                controller: postcodeController,
                hintText: 'POST CODE',
                obscureText: false,
                readOnly: true,
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
                      readOnly: true,
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
                      readOnly: true,
                      autofillHints: const [AutofillHints.telephoneNumber],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
