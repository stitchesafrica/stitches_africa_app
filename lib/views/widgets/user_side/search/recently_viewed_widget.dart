// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/recently_viewed_model.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';

class RecentlyViewedWidget extends StatelessWidget {
  final List<RecentlyViewedModel> recentlyViewedItems;
  RecentlyViewedWidget({super.key, required this.recentlyViewedItems});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
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

    return SizedBox(
      height: 170.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECENTLY VIEWED',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyViewedItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Utilities.backgroundColor));
                            });
                        final String productId =
                            recentlyViewedItems[index].productId;

                        final TailorWorkModel tailorWork =
                            await firebaseFirestoreFunctions
                                .getTailorWorksByProductID(productId);

                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TailorWorkDetails(
                            wishlistCollection: wishlistSubCollection,
                            cartCollection: cartSubCollection,
                            tailorId: tailorWork.tailorWorkID,
                            productId: tailorWork.productId,
                            images: tailorWork.images,
                            title: tailorWork.title,
                            description: tailorWork.description,
                            price: tailorWork.price,
                          );
                        }));
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 10.w),
                        width: 100.w,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: recentlyViewedItems[index].image,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Utilities.secondaryColor2,
                            highlightColor: Utilities.backgroundColor,
                            child: Container(
                              width: 180.w,
                              color: Utilities.secondaryColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  })),
          SizedBox(
            height: 25.h,
          ),
        ],
      ),
    );
  }
}
