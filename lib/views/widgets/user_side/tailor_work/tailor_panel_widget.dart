// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class TailorPanelWidget extends ConsumerStatefulWidget {
  final ScrollController controller;
  final CollectionReference wishlistCollection;
  final CollectionReference cartCollection;
  final String tailorId;
  final String productId;
  final List<String> images;
  final String title;
  final double price;
  final String description;

  const TailorPanelWidget({
    super.key,
    required this.controller,
    required this.tailorId,
    required this.title,
    required this.price,
    required this.description,
    required this.wishlistCollection,
    required this.cartCollection,
    required this.productId,
    required this.images,
  });

  @override
  ConsumerState<TailorPanelWidget> createState() => _TailorPanelWidgetState();
}

class _TailorPanelWidgetState extends ConsumerState<TailorPanelWidget> {
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification _showToasitification = ShowToasitification();
  bool _isBookmarked = false;

  /// Sets the initial wishlist state
  Future<void> _setWishlistState() async {
    final isBookmarked = await _firebaseFirestoreFunctions.getWishlistState(
      widget.wishlistCollection,
      widget.productId,
    );
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  /// Adds the product to the cart
  Future<void> _addToCart() async {
    _showLoadingDialog(context);

    final isAddedToCart = await _firebaseFirestoreFunctions.addToCart(
      ref,
      widget.cartCollection,
      widget.tailorId,
      widget.productId,
      widget.images,
      widget.title,
      widget.price,
      1,
    );

    Navigator.pop(context); // Dismiss loading dialog

    if (!isAddedToCart) {
      _showToasitification.showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: 'Cart item already added',
      );
    }
  }

  /// Toggles the wishlist state
  Future<void> _toggleWishlist() async {
    _showLoadingDialog(context);

    if (!_isBookmarked) {
      // Add to wishlist
      await _firebaseFirestoreFunctions.addWishlistItems(
        widget.wishlistCollection,
        widget.tailorId,
        widget.productId,
        widget.images,
        widget.title,
        widget.price,
      );
    } else {
      // Remove from wishlist
      await _firebaseFirestoreFunctions
          .deletWishlistItems(widget.title, widget.wishlistCollection)
          .then((_) => _firebaseFirestoreFunctions.wishlistStateHandler(
                widget.wishlistCollection,
                widget.title,
                false,
              ));
    }

    await _setWishlistState();
    Navigator.pop(context); // Dismiss loading dialog
  }

  /// Shows a loading dialog
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
  void initState() {
    super.initState();
    _setWishlistState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      controller: widget.controller,
      children: [
        /// Top Drag Handle
        Center(
          child: SvgPicture.asset(
            'assets/icons/minus.svg',
            height: 25.h,
            color: Utilities.primaryColor,
          ),
        ),
        SizedBox(height: 10.h),

        /// Product Title and Price
        Text(
          widget.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          '\$${widget.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 20.h),

        /// Add to Cart and Wishlist Buttons
        Row(
          children: [
            SizedBox(
              width: 290.w,
              child: Button(
                border: true,
                text: 'Add to Bag',
                onTap: _addToCart,
              ),
            ),
            SizedBox(width: 20.w),
            ButtonIconOnly(
              border: true,
              iconPath: _isBookmarked
                  ? 'assets/icons/bookmark_filled.svg'
                  : 'assets/icons/bookmark.svg',
              onTap: _toggleWishlist,
            ),
          ],
        ),
        SizedBox(height: 50.h),

        /// Product Description
        Text(
          widget.description,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
