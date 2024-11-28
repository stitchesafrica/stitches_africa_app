// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/cart_button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailors/refine_screen.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_works_widget.dart';

class TailorWearsCatalogScreen extends ConsumerWidget {
  final String docID;
  final String tailorName;
  final String? sortOption;

  TailorWearsCatalogScreen({
    super.key,
    required this.docID,
    required this.tailorName,
    this.sortOption,
  });

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  /// Retrieves the current user's ID from FirebaseAuth
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  Stream<List<TailorWorkModel>> _getTailorsWorksStream() {
    bool ascending = true; // Default sort order

    // Determine sort order based on the selected sort option
    if (sortOption == "Price (low first)") {
      ascending = true;
    } else if (sortOption == "Price (high first)") {
      ascending = false;
    }

    // Use the determined sort order to fetch sorted data
    return FirebaseFirestore.instance
        .collection('tailor_works')
        .where('id', isEqualTo: docID)
        .orderBy('price', descending: !ascending)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorWorkModel.fromDocument(doc.data()))
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
            ref.invalidate(groupValueProvider);
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
          tailorName.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20.sp,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          /// Cart Icon with Item Count
          CartButton(),
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
                    print(snapshot.error);
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
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: ButtonIcon(
                              text: 'Refine',
                              sizedBoxWidth: 5,
                              paddingWidth: 10.w,
                              paddingTop: 8.h,
                              iconPath: 'assets/icons/sort-by-line.svg',
                              border: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RefineScreen(),
                                  ),
                                ).then((selectedSortOption) {
                                  if (selectedSortOption != null) {
                                    context.pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TailorWearsCatalogScreen(
                                          docID: docID,
                                          tailorName: tailorName,
                                          sortOption: selectedSortOption,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12.5.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 75.w,
                            child: const Divider(
                              thickness: 0.5,
                              color: Utilities.secondaryColor2,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12.5.h,
                      ),
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
}
