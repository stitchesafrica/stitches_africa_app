// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/cart_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/services/api_service/logistics/terminal_africa_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/shopping_bag/checkout_screen.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/cart_items_stream_widget.dart';

class ShoppingBagScreen extends ConsumerWidget {
  ShoppingBagScreen({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  final TerminalAfricaApiService _terminalAfricaApiService =
      TerminalAfricaApiService();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  /// Firestore references
  DocumentReference _getAddressesDocRef() => FirebaseFirestore.instance
      .collection('users_addresses')
      .doc(getCurrentUserId());

  CollectionReference _getAddressesSubCollection() =>
      _getAddressesDocRef().collection('user_addresses');

  Future<void> _createDeliveryAddress() async {
    final data = await firebaseFirestoreFunctions
        .getUserFirstAddress(_getAddressesSubCollection());
    if (data != null) {
      print(data['flat_number']);
      final deliveryAddressModel =
          await _terminalAfricaApiService.createDeliveryAddress(
        city: data['city'],
        countryCode: data['country_code'],
        email: FirebaseAuth.instance.currentUser!.email!,
        isResidential: data['flat_number'].isNotEmpty ? true : false,
        firstName: data['first_name'],
        lastName: data['last_name'],
        line1: data['street_address'],
        phone: '${data['dial_code']}${data['phone_number']}',
        state: data['state'],
        postalCode: data['post_code'],
      );
      await firebaseFirestoreFunctions.updateShippingIds(getCurrentUserId(),
          {'delivery_address_id': deliveryAddressModel.addressId});
    }
  }

  Stream<List<CartModel>> getCartItemsStream() {
    return FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId())
        .collection('user_cart_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromDocument(doc.data(),
                totalItems: snapshot.docs.length))
            .toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int totalCartItems = ref.watch(totalCartItemsProvider);
    double totalPrice = ref.watch(totalPriceProvider);
    final DocumentReference wishlistDocRef = FirebaseFirestore.instance
        .collection('usersWishlistItems')
        .doc(getCurrentUserId());
    final DocumentReference addressesDocRef = FirebaseFirestore.instance
        .collection('users_addresses')
        .doc(getCurrentUserId());
    final CollectionReference addressesSubCollection =
        addressesDocRef.collection('user_addresses');
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
    final CollectionReference wishlistSubCollection =
        wishlistDocRef.collection('userWishlistItems');
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.h,
            ),
            Text(
              'SHOPPING BAG ($totalCartItems)',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 25.h,
            ),
            CartItemsStreamWidget(
              wishlistSubCollection: wishlistSubCollection,
              cartSubCollection: cartSubCollection,
              getCartItemsStream: getCartItemsStream(),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          height: 120.h,
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
                      'SUBTOTAL',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalPrice USD',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          'VAT NOT INCLUDED',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    )
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
                    bool doesTheUserHaveAddress =
                        await firebaseFirestoreFunctions
                            .checkIfUserHasAddress(addressesSubCollection);
                    if (doesTheUserHaveAddress) {
                      await _createDeliveryAddress();
                    }
                    context.pop();

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return CheckoutScreen(
                          doesTheUserHaveAddress: doesTheUserHaveAddress);
                    }));
                  })
            ],
          )),
    );
  }
}
