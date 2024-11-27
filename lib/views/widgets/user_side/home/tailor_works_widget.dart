// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class TailorWorksWidget extends StatefulWidget {
  final CollectionReference wishlistCollection;
  final List<String> imagePath;
  final String id;
  final String productId;
  final String title;
  final double price;
  final bool? wishlist;
  final bool? gridView;

  const TailorWorksWidget({
    super.key,
    required this.wishlistCollection,
    required this.productId,
    required this.imagePath,
    required this.title,
    required this.price,
    this.gridView,
    this.wishlist,
    required this.id,
  });

  @override
  State<TailorWorksWidget> createState() => _TailorWorksWidgetState();
}

class _TailorWorksWidgetState extends State<TailorWorksWidget> {
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  bool _isBookmarked = false;

  /// Sets the wishlist state by checking if the item is bookmarked
  Future<void> _setWishlistState() async {
    final isBookmarked = await _firebaseFirestoreFunctions.getWishlistState(
      widget.wishlistCollection,
      widget.productId,
    );

    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setWishlistState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Product Image
        Expanded(
          child: Container(
            margin:
                EdgeInsets.only(right: widget.gridView == true ? 0.w : 10.w),
            width: 180.w,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: widget.imagePath.first,
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image),
            ),
          ),
        ),
        SizedBox(height: 10.h),

        /// Product Details
        SizedBox(
          width: 180.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${widget.price} USD',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// Wishlist Icon
              GestureDetector(
                onTap: () async {
                  _toggleWishlistState(context);
                },
                child: SvgPicture.asset(
                  _isBookmarked
                      ? 'assets/icons/bookmark_filled.svg'
                      : 'assets/icons/bookmark.svg',
                  height: 20.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Toggles the wishlist state
  Future<void> _toggleWishlistState(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Utilities.backgroundColor,
          ),
        );
      },
    );

    if (!_isBookmarked) {
      // Add item to wishlist
      await _firebaseFirestoreFunctions
          .addWishlistItems(
            widget.wishlistCollection,
            widget.id,
            widget.productId,
            widget.imagePath,
            widget.title,
            widget.price,
          )
          .then((_) => _setWishlistState());
    } else {
      // Remove item from wishlist
      await _firebaseFirestoreFunctions
          .deletWishlistItems(widget.title, widget.wishlistCollection)
          .then((_) => _firebaseFirestoreFunctions.wishlistStateHandler(
                widget.wishlistCollection,
                widget.title,
                false,
              ))
          .then((_) => _setWishlistState());
    }

    Navigator.pop(context); // Dismiss the loading dialog
  }

  /// Builds a shimmer placeholder for loading images
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Utilities.secondaryColor2,
      highlightColor: Utilities.backgroundColor,
      child: Container(
        width: 180.w,
        color: Utilities.secondaryColor,
      ),
    );
  }
}
