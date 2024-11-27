// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/address_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/logistics/terminal_africa_models/get_rates_model.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/address/add_new_address.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/shopping_bag/authorize_payment.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/address_stream.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/checkout_items_stream_widget.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final bool doesTheUserHaveAddress;
  const CheckoutScreen({
    super.key,
    required this.doesTheUserHaveAddress,
  });

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final TerminalAfricaApiService _terminalAfricaApiService =
      TerminalAfricaApiService();
  String? _selectedOption = 'Standard Shipping';

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<AddressModel>> getUserAddresses() {
    return FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId())
        .collection('user_addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromDocument(doc.data()))
            .toList());
  }

  Stream<List<CartModel>> getCartItemsStream() {
    return FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId())
        .collection('user_cart_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromDocument(doc.data()))
            .toList());
  }

  Future<GetRatesModel> getRates() async {
    final shippingData = await _firebaseFirestoreFunctions
        .getShippingDetails(getCurrentUserId());

    final getRatesModel = await _terminalAfricaApiService.getRates(
      pickUpAddressId: shippingData!['pickup_address_id'],
      deliveryAddressId: shippingData['delivery_address_id'],
      parcelId: shippingData['parcel_id'],
      cashOnDelivery: false,
    );
    await _firebaseFirestoreFunctions.updateShippingIds(
        getCurrentUserId(), {'rate_id': getRatesModel.rateId});
    return getRatesModel;
  }

  // // Calculate shipping dates

  String convertToFormattedDate(String isoDateString) {
    DateTime dateTime = DateTime.parse(isoDateString);

    String formattedDate = DateFormat('EEEE d, MMMM').format(dateTime);

    return formattedDate;
  }

  /// Builds a shimmer placeholder for loading images
  Widget _buildShimmerPlaceholder(double? width, double height) {
    return SizedBox(
      height: height,
      width: width,
      child: Shimmer.fromColors(
        baseColor: Utilities.secondaryColor2,
        highlightColor: Utilities.backgroundColor,
        child: Container(
          color: Utilities.secondaryColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.doesTheUserHaveAddress) {
      return buildIfUserHasNoAddressSaved();
    } else {
      return buildIfUserHasAddressSaved(context, ref);
    }
  }

  Widget buildIfUserHasNoAddressSaved() {
    return const AddNewAddress(didItComeFromCheckoutScreen: true);
  }

  Widget buildIfUserHasAddressSaved(BuildContext context, WidgetRef ref) {
    AddressModel? selectedAddress = ref.watch(selectedAddressProvider);
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
        title: Text(
          'CHECKOUT',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16.sp,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              'Delivery Address',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.spMin,
                //letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const Divider(
            thickness: 0.5,
            color: Utilities.primaryColor,
          ),
          SizedBox(
            height: 10.h,
          ),
          if (selectedAddress != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedAddress.streetAddress.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  AddressStrem2(getUserAddressesStream: getUserAddresses())
                ],
              ),
            )
          else
            AddressStream(getUserAddressesStream: getUserAddresses()),
          SizedBox(
            height: 10.h,
          ),
          const Divider(
            thickness: 0.5,
            color: Utilities.primaryColor,
          ),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              'Items',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.spMin,
                // letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          CheckoutItemsStreamWidget(getCartItemsStream: getCartItemsStream()),
          SizedBox(
            height: 20.h,
          ),

          if (mounted)
            FutureBuilder(
                future: getRates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerPlaceholder(null, 50.h);
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  }
                  final data = snapshot.data!;
                  return RadioListTile<String>(
                    value: 'Standard Shipping',
                    groupValue: _selectedOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
                    activeColor: Colors.black,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            convertToFormattedDate(data.deliveryDate)
                                .toUpperCase(),
                            style: TextStyle(
                              color: Utilities.primaryColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.spMin,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        Text(
                          '${data.shippingFee} USD',
                          style: TextStyle(
                              color: Utilities.primaryColor, fontSize: 12.sp),
                        ),
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        const Icon(
                          FluentSystemIcons.ic_fluent_info_regular,
                          size: 12,
                          color: Utilities.secondaryColor,
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Text(
                          'Standard shipping',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: Utilities.secondaryColor,
                              fontWeight: FontWeight.w400),
                        )
                      ],
                    ),
                  );
                }),
          // Standard Shipping Option
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          height: 100.h,
          elevation: 0,
          color: Utilities.backgroundColor,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SHIPPING',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    if (mounted)
                      FutureBuilder(
                          future: getRates(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildShimmerPlaceholder(50.w, 20.h);
                            } else if (snapshot.hasError) {
                              return const Center(
                                child: Text('An error occurred'),
                              );
                            }
                            final data = snapshot.data!;
                            return Text(
                              '${data.shippingFee} USD',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            );
                          }),
                  ],
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Button(
                  border: false,
                  text: 'Continue',
                  onTap: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor),
                      ),
                    );
                    final getRatesModel = await getRates();
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AuthorizePaymentScreen(
                        deliveryFee: getRatesModel.shippingFee,
                        deliveryDate:
                            convertToFormattedDate(getRatesModel.deliveryDate),
                        getCartItemsStream: getCartItemsStream(),
                        getUserAddresses: getUserAddresses(),
                      );
                    }));
                  })
            ],
          )),
    );
  }
}
