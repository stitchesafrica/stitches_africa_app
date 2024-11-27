// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/cart_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/price_model.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/services/api_service/price_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/services/location_service/location_service.dart';
import 'package:stitches_africa/services/payment/paystack_payment_service.dart';
import 'package:stitches_africa/services/storage_services/secure_storage_service.dart';
import 'package:stitches_africa/views/components/button.dart';

class ShoppingPanelWidget extends ConsumerWidget {
  final ScrollController controller;
  final double shippingCost;
  final String deliveryDate;
  final Map<String, dynamic>? userAddress;
  ShoppingPanelWidget({
    super.key,
    required this.controller,
    required this.shippingCost,
    required this.deliveryDate,
    required this.userAddress,
  });

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String countryCode = '';
  final priceService = PriceServiceApi();
  final locationService = LocationService();
  final storage = SecureServiceStorage();

  String? _getCurrentUserEmail() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String? userID = currentUser.email;
    return userID;
  }

  Future<Price> fetchPrice(BuildContext context) async {
    try {
      final country = await locationService.getCountry(context);
      final countryInfo = await locationService.findCountryData(country);
      final String? ctryCode = countryInfo!['Code'];
      countryCode = ctryCode ?? '\$';
      if (kDebugMode) {
        print('Country: $country');
        print('Country Info: $countryInfo');
        print('Currency Code: $countryCode');
      }
      if (countryCode == 'NGN') {
        final price = await priceService.getForexPrice('USD', countryCode);
        return price;
      } else if (countryCode == 'GHS') {
        final price = await priceService.getForexPrice('USD', countryCode);
        return price;
      } else if (countryCode == 'KES') {
        final price = await priceService.getForexPrice('USD', countryCode);
        return price;
      } else if (countryCode == 'ZAR') {
        final price = await priceService.getForexPrice('USD', countryCode);
        return price;
      } else {
        final price = await priceService.getForexPrice('USD', 'USD');
        if (kDebugMode) {
          print('Country Code: $countryCode');
          print('Price: $price');
        }
        return price;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future makePayment(BuildContext context, double totalPrice) async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    final Price priceModel = await fetchPrice(context);
    final String? testPublicKey = await storage.retrievePaystackApiKey();
    Navigator.pop(context);
    final double price =
        priceModel.currencyExchangeRate * (totalPrice + shippingCost);

    PaystackPaymentServices(
            context: context,
            //subName: 'Jeffrey Benson',
            selectedAddress: userAddress,
            deliveryDate: deliveryDate,
            publicKey: testPublicKey ?? '',
            countryCode: countryCode,
            price: price.round(),
            userEmail: _getCurrentUserEmail())
        .chargeAndMakePayment();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool onPanelOpened = ref.watch(onPanelOpenedProvider);

    return onPanelOpened
        ? _buildOnPanelOpened(context, ref)
        : _buildOnPanelClosed(context, ref);
  }

  Widget _buildOnPanelOpened(BuildContext context, WidgetRef ref) {
    int totalCartItems = ref.watch(totalCartItemsProvider);
    double totalPrice = ref.watch(totalPriceProvider);
    return ListView(
      children: [
        SvgPicture.asset(
          'assets/icons/minus.svg',
          height: 25.h,
          color: Utilities.primaryColor,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalCartItems ITEMS',
                style:
                    TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w400),
              ),
              Text(
                '$totalPrice USD',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SHIPPING',
                style:
                    TextStyle(fontSize: 14.spMin, fontWeight: FontWeight.w400),
              ),
              Text(
                '$shippingCost USD',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(totalPrice + shippingCost).round()} USD',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
        Button(border: false, text: 'Authorize Payment', onTap: () async {})
      ],
    );
  }

  Widget _buildOnPanelClosed(BuildContext context, WidgetRef ref) {
    double totalPrice = ref.watch(totalPriceProvider);
    return ListView(children: [
      SvgPicture.asset(
        'assets/icons/minus.svg',
        height: 25.h,
        color: Utilities.primaryColor,
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              '${(totalPrice + shippingCost).round()} USD',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 20.h,
      ),
      Button(
          border: false,
          text: 'Authorize Payment',
          onTap: () async {
            await makePayment(context, totalPrice);
          })
    ]);
  }
}
