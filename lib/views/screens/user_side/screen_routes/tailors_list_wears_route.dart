import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_work_details.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_works_widget.dart';

class TailorsListWearsRoute extends ConsumerStatefulWidget {
  final CollectionReference favoriteCollection;
  final List<Map<String, dynamic>>? selectedTailors;

  final String? tailorId;
  final String? tailorName;
  const TailorsListWearsRoute({
    super.key,
    required this.favoriteCollection,
    this.selectedTailors,
    this.tailorId,
    this.tailorName,
  });

  @override
  ConsumerState<TailorsListWearsRoute> createState() =>
      _TailorsListWearsRouteState();
}

class _TailorsListWearsRouteState extends ConsumerState<TailorsListWearsRoute> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  bool isFavorite = false;

  Future<void> setFavoriteState() async {
    final temporaryBookmarkedState =
        await firebaseFirestoreFunctions.getFavoriteState(
            widget.favoriteCollection,
            (widget.selectedTailors?.isNotEmpty == true
                ? widget.selectedTailors!.first['id']
                : widget.tailorId));

    if (mounted) {
      setState(() {
        isFavorite = temporaryBookmarkedState;
      });
    }
  }

  Future<void> toggleFavoriteState(String tailorId, String brandName) async {
    // Add/remove from favorites in Firestore
    if (!isFavorite) {
      await firebaseFirestoreFunctions
          .addFavoriteTailor(
            widget.favoriteCollection,
            brandName,
            tailorId,
          )
          .then((value) => setFavoriteState());
    } else {
      await firebaseFirestoreFunctions
          .deleteFavoriteTailor(
            tailorId,
            widget.favoriteCollection,
          )
          .then((value) => setFavoriteState());
    }
  }

  Stream<List<TailorWorkModel>> getOneTailorWorksStream() {
    return FirebaseFirestore.instance
        .collection('tailor_works')
        .where('id',
            isEqualTo: (widget.selectedTailors?.isNotEmpty == true
                ? widget.selectedTailors!.first['id']
                : widget.tailorId))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorWorkModel.fromDocument(doc.data()))
            .toList());
  }

  Future<List<TailorWorkModel>> getAllTailorsWorks() async {
    List<TailorWorkModel> allWorks = [];

    for (var tailor in widget.selectedTailors!) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('tailor_works')
          .where('id', isEqualTo: tailor['id'])
          .get();

      final works = querySnapshot.docs
          .map((doc) => TailorWorkModel.fromDocument(doc.data()))
          .toList();

      allWorks.addAll(works); // Add works for this tailor to the master list
    }

    return allWorks; // Return the combined list of all works
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  void initState() {
    super.initState();
    setFavoriteState();
  }

  @override
  Widget build(BuildContext context) {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
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
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              await firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);
              Navigator.pop(context);
              context.pushNamed('shoppingScreen');
            },
            child: SvgPicture.asset(
              'assets/icons/bag.svg',
              height: 22.h,
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: (widget.selectedTailors?.length ?? 1) == 1
          ? buildIfItsOneTailorSelected()
          : buildIfItsMultipleTailorsSelected(),
    );
  }

  Widget buildIfItsOneTailorSelected() {
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  isFavorite
                      ? FluentSystemIcons.ic_fluent_heart_filled
                      : FluentSystemIcons.ic_fluent_heart_regular,
                  size: 48,
                  color: Utilities.primaryColor,
                ),
                onPressed: () => toggleFavoriteState(
                    (widget.selectedTailors?.isNotEmpty == true
                        ? widget.selectedTailors!.first['id']
                        : widget.tailorId),
                    (widget.selectedTailors?.isNotEmpty == true
                        ? widget.selectedTailors!.first['brand_name']
                        : widget.tailorName)),
              ),
            ],
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            (widget.selectedTailors?.isNotEmpty == true
                ? widget.selectedTailors!.first['brand_name']
                : widget.tailorName),
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: StreamBuilder<List<TailorWorkModel>>(
                stream: getOneTailorWorksStream(),
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
                      child: Text(
                        'No work found',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }
                  final tailorWorks = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tailorWorks.length} wears',
                            style: TextStyle(
                              fontSize: 16.sp,
                              //letterSpacing: 1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Expanded(
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 300,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 20.h,
                            ),
                            itemCount: tailorWorks.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return TailorWorkDetails(
                                      wishlistCollection: wishlistSubCollection,
                                      tailorId: tailorWorks[index].tailorWorkID,
                                      cartCollection: cartSubCollection,
                                      productId: tailorWorks[index].productId,
                                      images: tailorWorks[index].images,
                                      title: tailorWorks[index].title,
                                      price: tailorWorks[index].price,
                                      description:
                                          tailorWorks[index].description,
                                    );
                                  }));
                                },
                                child: TailorWorksWidget(
                                  wishlistCollection: wishlistSubCollection,
                                  id: tailorWorks[index].productId,
                                  productId: tailorWorks[index].productId,
                                  imagePath: tailorWorks[index].images,
                                  title: tailorWorks[index].title,
                                  price: tailorWorks[index].price,
                                  gridView: true,
                                ),
                              );
                            }),
                      )
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget buildIfItsMultipleTailorsSelected() {
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your selected items',
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: FutureBuilder<List<TailorWorkModel>>(
                future: getAllTailorsWorks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  } else if (snapshot.hasError) {
                    print(snapshot.error);
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
                        child: Text(
                      'No work found',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ));
                  }
                  final tailorWorks = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${tailorWorks.length} wears',
                            style: TextStyle(
                              fontSize: 16.sp,
                              //letterSpacing: 1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Expanded(
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: 300,
                              crossAxisCount: 2,
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 20.h,
                            ),
                            itemCount: tailorWorks.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return TailorWorkDetails(
                                      wishlistCollection: wishlistSubCollection,
                                      tailorId: tailorWorks[index].tailorWorkID,
                                      cartCollection: cartSubCollection,
                                      productId: tailorWorks[index].productId,
                                      images: tailorWorks[index].images,
                                      title: tailorWorks[index].title,
                                      price: tailorWorks[index].price,
                                      description: tailorWorks[index].description,
                                    );
                                  }));
                                },
                                child: TailorWorksWidget(
                                  wishlistCollection: wishlistSubCollection,
                                  id: tailorWorks[index].productId,
                                  productId: tailorWorks[index].productId,
                                  imagePath: tailorWorks[index].images,
                                  title: tailorWorks[index].title,
                                  price: tailorWorks[index].price,
                                  gridView: true,
                                ),
                              );
                            }),
                      )
                    ],
                  );
                }),
          ),
        ],
      ),
    );
  }
}
