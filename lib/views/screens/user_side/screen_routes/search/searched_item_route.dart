// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_works_widget.dart';
import 'package:toastification/toastification.dart';

class SearchedItemRoute extends ConsumerWidget {
  final String searchTerm;
  final int hits;
  SearchedItemRoute({
    super.key,
    required this.searchTerm,
    required this.hits,
  });

  final Algolia algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification showToasitification = ShowToasitification();
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  //algolia search query function
  Future<List<AlgoliaObjectSnapshot>> queryOperation(
      BuildContext context) async {
    try {
      AlgoliaQuery query =
          algoliaApp.instance.index('tailor_works_index').query(searchTerm);

      AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
      List<AlgoliaObjectSnapshot> results = querySnapshot.hits;

      if (kDebugMode) {
        print('Searched Items: $results');
      }
      return results;
    } catch (e) {
      showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: 'Error searching for tailor work');
      if (kDebugMode) {
        print('Error searching: $e');
      }
      rethrow;
    }
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    final CollectionReference userViewedItemsCollection = FirebaseFirestore
        .instance
        .collection('users_viewed_items')
        .doc(getCurrentUserId())
        .collection('user_viewed_items');
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
        centerTitle: true,
        title: Column(
          children: [
            Text(
              searchTerm,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              '$hits items',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
            )
          ],
        ),
        actions: [
          SvgPicture.asset(
            'assets/icons/bag.svg',
            height: 22.h,
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            const Divider(
              thickness: 0.5,
              color: Utilities.secondaryColor2,
            ),
            SizedBox(
              height: 20.h,
            ),
            FutureBuilder(
                future: queryOperation(context),
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
                      child: Text('No wears found'),
                    );
                  }
                  List<AlgoliaObjectSnapshot> currentSearchResult =
                      snapshot.data!;
                  if (kDebugMode) {
                    print('Number of hits: ${currentSearchResult.length}');
                  }
                  return Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: 320,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 20.h,
                        ),
                        itemCount: currentSearchResult.length,
                        itemBuilder: (context, index) {
                          final Map<String, dynamic> documentSnapshot =
                              currentSearchResult[
                                      currentSearchResult.length - (index + 1)]
                                  .data;

                          return GestureDetector(
                            onTap: () {
                              firebaseFirestoreFunctions
                                  .addUserRecentlyViewedItems(
                                userViewedItemsCollection,
                                documentSnapshot['product_id'],
                                documentSnapshot['images'].first,
                                documentSnapshot['category'],
                              );
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TailorWorkDetails(
                                  wishlistCollection: wishlistSubCollection,
                                  cartCollection: cartSubCollection,
                                  tailorId: documentSnapshot['id'],
                                  productId: documentSnapshot['product_id'],
                                  images: List<String>.from(
                                      documentSnapshot['images']),
                                  title: documentSnapshot['title'],
                                  price: documentSnapshot['price'],
                                  description: documentSnapshot['description'],
                                );
                              }));
                            },
                            child: TailorWorksWidget(
                              wishlistCollection: wishlistSubCollection,
                              id: documentSnapshot['id'],
                              productId: documentSnapshot['product_id'],
                              imagePath:
                                  List<String>.from(documentSnapshot['images']),
                              title: documentSnapshot['title'],
                              price: documentSnapshot['price'],
                              gridView: true,
                            ),
                          );
                        }),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
