import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/wishlist_model.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/wishlist/wishlist_widget.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<WishlistModel>> getWishlistStream() {
    return FirebaseFirestore.instance
        .collection('usersWishlistItems')
        .doc(getCurrentUserId())
        .collection('userWishlistItems')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WishlistModel.fromDocument(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    final DocumentReference wishlistDocRef = FirebaseFirestore.instance
        .collection('usersWishlistItems')
        .doc(getCurrentUserId());
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference wishlistSubCollection =
        wishlistDocRef.collection('userWishlistItems');
    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),
            Text(
              'FAVORITES',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
                child: StreamBuilder(
                    stream: getWishlistStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Utilities.backgroundColor));
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('An error occurred'),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text(
                          'Your wishlist is empty',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ));
                      }
                      final wishlistData = snapshot.data!;

                      return Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  // mainAxisExtent: 300,
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.5,
                                  crossAxisSpacing: 10.w,
                                  mainAxisSpacing: 20.h,
                                ),
                                itemCount: wishlistData.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return TailorWorkDetails(
                                          wishlistCollection:
                                              wishlistSubCollection,
                                          cartCollection: cartSubCollection,
                                          tailorId: wishlistData[index].id,
                                          productId: wishlistData[index].id,
                                          images: wishlistData[index].images,
                                          title: wishlistData[index].title,
                                          price: wishlistData[index].price,
                                          description:
                                              wishlistData[index].description,
                                        );
                                      }));
                                    },
                                    child: WishlistWidget(
                                      wishlistCollection: wishlistSubCollection,
                                      cartCollection: cartSubCollection,
                                      tailorWorkID: wishlistData[index].id,
                                      productId: wishlistData[index].productId,
                                      imagePath: wishlistData[index].images,
                                      title: wishlistData[index].title,
                                      price: wishlistData[index].price,
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    })),
          ],
        ),
      ),
    );
  }
}
