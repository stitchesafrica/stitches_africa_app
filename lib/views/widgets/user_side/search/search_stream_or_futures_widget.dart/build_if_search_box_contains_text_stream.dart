import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_works_widget.dart';

class BuildIfSearchBoxContainsTextStream extends StatelessWidget {
  final CollectionReference wishlistSubCollection;
  final CollectionReference cartCollection;
  final Future<List<AlgoliaObjectSnapshot>> querySnapshot;
  BuildIfSearchBoxContainsTextStream(
      {super.key,
      required this.wishlistSubCollection,
      required this.cartCollection,
      required this.querySnapshot});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference userViewedItemsCollection = FirebaseFirestore
        .instance
        .collection('users_viewed_items')
        .doc(getCurrentUserId())
        .collection('user_viewed_items');

    return StreamBuilder(
        stream: Stream.fromFuture(querySnapshot),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          } else if (snapshot.hasError) {
            if (Platform.isIOS) {
              return IOSAlertDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  },
                  isDefaultAction1: true,
                  isDestructiveAction1: false);
            } else {
              return AndriodAleartDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  });
            }
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No work found'),
            );
          }
          List<AlgoliaObjectSnapshot> currentSearchResult = snapshot.data!;
          if (kDebugMode) {
            print('Number of hits: ${currentSearchResult.length}');
          }
          return Expanded(
            child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: 300,
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
                      firebaseFirestoreFunctions.addUserRecentlyViewedItems(
                        userViewedItemsCollection,
                        documentSnapshot['product_id'],
                        documentSnapshot['images'].first,
                        documentSnapshot['category'],
                      );
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return TailorWorkDetails(
                          wishlistCollection: wishlistSubCollection,
                          cartCollection: cartCollection,
                          tailorId: documentSnapshot['id'],
                          productId: documentSnapshot['product_id'],
                          images: List<String>.from(documentSnapshot['images']),
                          title: documentSnapshot['title'],
                          description: documentSnapshot['description'],
                          price: documentSnapshot['price'],
                        );
                      }));
                    },
                    child: TailorWorksWidget(
                      wishlistCollection: wishlistSubCollection,
                      id: documentSnapshot['id'],
                      productId: documentSnapshot['product_id'],
                      imagePath: List<String>.from(documentSnapshot['images']),
                      title: documentSnapshot['title'],
                      price: documentSnapshot['price'],
                      gridView: true,
                    ),
                  );
                }),
          );
        });
  }
}
