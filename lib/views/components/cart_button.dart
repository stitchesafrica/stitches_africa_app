import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class CartButton extends ConsumerWidget {
  CartButton({super.key});

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  /// Retrieves the current user's ID from FirebaseAuth
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Stream of cart items for the current user
  Stream<List<CartModel>> _getCartItemsStream() {
    return FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromDocument(
                  doc.data(),
                  totalItems: snapshot.docs.length,
                ))
            .toList());
  }

  /// Displays a loading dialog
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
    final cartSubCollection = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items');

    return GestureDetector(
      onTap: () async {
        _showLoadingDialog(context);
        await _firebaseFirestoreFunctions.refreshCart(ref, cartSubCollection);
        context.pop(); // Close loading dialog
        context.pushNamed('shoppingScreen');
      },
      child: Row(
        children: [
          StreamBuilder<List<CartModel>>(
            stream: _getCartItemsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  '...',
                  style: TextStyle(fontSize: 12.sp),
                );
              } else if (snapshot.hasData) {
                final totalItems = snapshot.data!.isEmpty
                    ? 0
                    : snapshot.data!.first.totalItems;
                return Text(
                  '$totalItems',
                  style: TextStyle(fontSize: 12.sp),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          SizedBox(width: 3.w),
          SvgPicture.asset(
            'assets/icons/bag.svg',
            height: 22.h,
          ),
        ],
      ),
    );
  }
}
