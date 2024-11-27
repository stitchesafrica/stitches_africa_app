// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_works_widget.dart';

class TailorScreen extends ConsumerWidget {
  final String docID;
  final String tailorName;

  TailorScreen({super.key, required this.docID, required this.tailorName});

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  /// Retrieves the current user's ID from FirebaseAuth
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Stream of tailor's works based on the tailor's document ID
  Stream<List<TailorWorkModel>> _getTailorsWorksStream() {
    return FirebaseFirestore.instance
        .collection('tailor_works')
        .where('id', isEqualTo: docID)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorWorkModel.fromDocument(doc.data()))
            .toList());
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define Firestore references for wishlist and cart
    final wishlistSubCollection = FirebaseFirestore.instance
        .collection('usersWishlistItems')
        .doc(_getCurrentUserId())
        .collection('userWishlistItems');
    final cartSubCollection = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items');

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
        actions: [
          /// Cart Icon with Item Count
          GestureDetector(
            onTap: () async {
              _showLoadingDialog(context);
              await _firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);
              Navigator.pop(context); // Close loading dialog
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
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            /// Tailor Works StreamBuilder
            Expanded(
              child: StreamBuilder<List<TailorWorkModel>>(
                stream: _getTailorsWorksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Utilities.backgroundColor,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No wears found',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }

                  // Display the list of tailor works
                  final tailorWorks = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tailorName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 22.sp,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 300,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 20.h,
                          ),
                          itemCount: tailorWorks.length,
                          itemBuilder: (context, index) {
                            final work = tailorWorks[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TailorWorkDetails(
                                      wishlistCollection: wishlistSubCollection,
                                      tailorId: work.tailorWorkID,
                                      cartCollection: cartSubCollection,
                                      productId: work.productId,
                                      images: work.images,
                                      title: work.title,
                                      description: work.description,
                                      price: work.price,
                                    ),
                                  ),
                                );
                              },
                              child: TailorWorksWidget(
                                wishlistCollection: wishlistSubCollection,
                                id: work.tailorWorkID,
                                productId: work.productId,
                                imagePath: work.images,
                                title: work.title,
                                price: work.price,
                                gridView: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
}
