// ignore_for_file: use_build_context_synchronously, unused_import

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/wishlist_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';

class WishlistWidget extends ConsumerStatefulWidget {
  final CollectionReference wishlistCollection;
  final CollectionReference cartCollection;
  final List<String> imagePath;
  final String tailorWorkID;
  final String productId;
  final String title;
  final double price;

  const WishlistWidget(
      {super.key,
      required this.wishlistCollection,
      required this.imagePath,
      required this.tailorWorkID,
      required this.productId,
      required this.title,
      required this.price,
      required this.cartCollection});

  @override
  ConsumerState<WishlistWidget> createState() => _WishlistWidgetState();
}

class _WishlistWidgetState extends ConsumerState<WishlistWidget> {
  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  bool isBookmarked = false;

  Future<void> setWishlistState() async {
    final temporaryBookmarkedState = await firebaseFirestoreFunctions
        .getWishlistState(widget.wishlistCollection, widget.productId);

    if (mounted) {
      setState(() {
        isBookmarked = temporaryBookmarkedState;
      });
    }
  }

  Future<void> addToCart() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    await firebaseFirestoreFunctions.addToCart(
        ref,
        widget.cartCollection,
        widget.tailorWorkID,
        widget.productId,
        widget.imagePath,
        widget.title,
        widget.price,
        1);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    setWishlistState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: 180.w,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.imagePath.first,
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
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 180.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${widget.price} USD',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (!isBookmarked) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        });
                    await firebaseFirestoreFunctions
                        .addWishlistItems(
                            widget.wishlistCollection,
                            widget.tailorWorkID,
                            widget.productId,
                            widget.imagePath,
                            widget.title,
                            widget.price)
                        .then((value) => setWishlistState());
                    Navigator.pop(context);
                  } else {
                    // showDialog(
                    //     context: context,
                    //     builder: (context) {
                    //       return const Center(
                    //           child: CircularProgressIndicator(
                    //               color: Utilities.backgroundColor));
                    //     });
                    await firebaseFirestoreFunctions
                        .deletWishlistItems(
                            widget.title, widget.wishlistCollection)
                        .then((value) async {
                      await firebaseFirestoreFunctions
                          .wishlistStateHandler(
                              widget.wishlistCollection, widget.title, false)
                          .then((value) => setWishlistState());
                    });
                    // Navigator.pop(context);
                    // Navigator.pop(context);
                  }
                },
                child: SvgPicture.asset(
                  isBookmarked
                      ? 'assets/icons/bookmark_filled.svg'
                      : 'assets/icons/bookmark.svg',
                  height: 20.h,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        Button(
          border: true,
          text: 'Add to Bag',
          onTap: () async {
            await addToCart();
          },
        ),
      ],
    );
  }
}
