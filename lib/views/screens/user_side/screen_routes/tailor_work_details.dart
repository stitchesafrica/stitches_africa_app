import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/user_side/tailor_work/tailor_panel_widget.dart';

class TailorWorkDetails extends ConsumerWidget {
  final CollectionReference wishlistCollection;
  final CollectionReference cartCollection;
  final String tailorId;
  final String productId;
  final List<String> images;
  final String title;
  final double price;
  final String description;

  TailorWorkDetails({
    super.key,
    required this.wishlistCollection,
    required this.cartCollection,
    required this.images,
    required this.title,
    required this.price,
    required this.description,
    required this.tailorId,
    required this.productId,
  });

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final PageController _pageController = PageController();

  /// Retrieves the current user's ID from FirebaseAuth
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
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

  /// Shows a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Utilities.backgroundColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CollectionReference cartSubCollection = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items');

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
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
              Navigator.pop(context); // Dismiss loading dialog
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
      body: SlidingUpPanel(
        minHeight: MediaQuery.of(context).size.height * 0.2,
        maxHeight: MediaQuery.of(context).size.height,
        body: Stack(
          alignment: Alignment.centerRight,
          children: [
            /// Image Carousel
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: images[index],
                  placeholder: (context, url) => _buildShimmerPlaceholder(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.broken_image),
                );
              },
            ),

            /// Vertical Page Indicator
            Padding(
              padding: EdgeInsets.only(right: 15.w),
              child: SmoothPageIndicator(
                axisDirection: Axis.vertical,
                controller: _pageController,
                count: images.length,
                effect: ExpandingDotsEffect(
                  expansionFactor: 4.5.w,
                  dotWidth: 11.w,
                  dotHeight: 5.h,
                  radius: 0.r,
                  activeDotColor: Utilities.primaryColor,
                  dotColor: Utilities.secondaryColor3,
                ),
              ),
            ),
          ],
        ),

        /// Panel Content
        panelBuilder: (controller) => TailorPanelWidget(
          controller: controller,
          wishlistCollection: wishlistCollection,
          cartCollection: cartCollection,
          tailorId: tailorId,
          productId: productId,
          images: images,
          title: title,
          price: price,
          description: description,
        ),
      ),
    );
  }

  /// Builds a shimmer placeholder for loading images
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Utilities.secondaryColor2,
      highlightColor: Utilities.backgroundColor,
      child: Container(
        color: Utilities.secondaryColor,
      ),
    );
  }
}

