// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/address_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/address/edit_address.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/shopping_bag/checkout_screen.dart';
import 'package:toastification/toastification.dart';

class AddressListWidget extends ConsumerWidget {
  final AddressModel addressData;
  final int index;
  final int length;
  AddressListWidget(
      {super.key,
      required this.addressData,
      required this.index,
      required this.length});
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final TerminalAfricaApiService _terminalAfricaApiService =
      TerminalAfricaApiService();
  final ShowToasitification showToasitification = ShowToasitification();

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  /// Firestore references
  DocumentReference _getAddressesDocRef() => FirebaseFirestore.instance
      .collection('users_addresses')
      .doc(_getCurrentUserId());

  CollectionReference _getAddressesSubCollection() =>
      _getAddressesDocRef().collection('user_addresses');

  void _chooseAddress(BuildContext context, WidgetRef ref) async {
    ref.read(selectedAddressProvider.notifier).state = addressData;
    _showLoadingDialog(context);
    final deliveryAddressModel =
        await _terminalAfricaApiService.createDeliveryAddress(
            city: addressData.city,
            countryCode: addressData.countryCode,
            email: FirebaseAuth.instance.currentUser!.email!,
            isResidential: addressData.flatNumber != null ? true : false,
            firstName: addressData.firstName,
            lastName: addressData.lastName,
            line1: addressData.streetAddress,
            phone: '${addressData.dialCode}${addressData.phoneNumber}',
            state: addressData.state,
            postalCode: addressData.postcode);
    await firebaseFirestoreFunctions.updateShippingIds(_getCurrentUserId(),
        {'delivery_address_id': deliveryAddressModel.addressId});
    bool doesTheUserHaveAddress = await firebaseFirestoreFunctions
        .checkIfUserHasAddress(_getAddressesSubCollection());
    context.pop();
    context.pop();
    context.pop();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CheckoutScreen(doesTheUserHaveAddress: doesTheUserHaveAddress);
    }));
  }

  /// Shows a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          thickness: 0.5,
          color: Utilities.primaryColor,
        ),
        SizedBox(
          height: 10.h,
        ),
        InkWell(
          onTap: () async {
            _chooseAddress(context, ref);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${addressData.firstName} ${addressData.lastName}'
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      addressData.streetAddress,
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    addressData.flatNumber != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 2.h,
                              ),
                              Text(
                                addressData.flatNumber!,
                                style: TextStyle(
                                  fontSize: 14.spMin,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      '${addressData.postcode}, ${addressData.city}',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      addressData.country,
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                    Text(
                      '${addressData.dialCode} ${addressData.phoneNumber}',
                      style: TextStyle(
                        fontSize: 14.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Utilities.backgroundColor));
                            });
                        String? docId = await firebaseFirestoreFunctions
                            .getUserAddressDocId(
                          _getAddressesSubCollection(),
                          addressData.firstName,
                          addressData.lastName,
                          addressData.country,
                          addressData.streetAddress,
                          addressData.flatNumber,
                          addressData.state,
                          addressData.city,
                          addressData.postcode,
                          addressData.dialCode,
                          addressData.phoneNumber,
                        );
                        Navigator.pop(context);
                        if (docId != null) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return EditAddressScreen(
                              addressModelData: addressData,
                              docId: docId,
                            );
                          }));
                        } else {
                          showToasitification.showToast(
                              context: context,
                              toastificationType: ToastificationType.error,
                              title: 'Something went wrong');
                        }
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        if (index + 1 == length)
          const Divider(
            thickness: 0.5,
            color: Utilities.primaryColor,
          ),
      ],
    );
  }
}
