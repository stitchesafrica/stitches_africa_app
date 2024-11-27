// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/cart_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class ShoppingItemsWidget extends ConsumerStatefulWidget {
  final CollectionReference wishlistCollection;
  final CollectionReference cartCollection;
  final String id;
  final String productId;
  final List<String> images;
  final String itemName;
  final double price;
  final int quantity;
  final int index;
  const ShoppingItemsWidget(
      {super.key,
      required this.images,
      required this.itemName,
      required this.index,
      required this.id,
      required this.productId,
      required this.price,
      required this.quantity,
      required this.wishlistCollection,
      required this.cartCollection});

  @override
  ConsumerState<ShoppingItemsWidget> createState() =>
      _ShoppingItemsWidgetState();
}

class _ShoppingItemsWidgetState extends ConsumerState<ShoppingItemsWidget> {
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

  Future<void> updateWishlist() async {
    if (!isBookmarked) {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          });
      await firebaseFirestoreFunctions
          .addWishlistItems(widget.wishlistCollection, widget.id,
              widget.productId, widget.images, widget.itemName, widget.price)
          .then((value) => setWishlistState());
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          });
      await firebaseFirestoreFunctions
          .deletWishlistItems(widget.itemName, widget.wishlistCollection)
          .then((value) async {
        await firebaseFirestoreFunctions
            .wishlistStateHandler(
                widget.wishlistCollection, widget.itemName, false)
            .then((value) => setWishlistState());
      });
      Navigator.pop(context);
    }
  }

  Future<void> deletcartItem() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    await firebaseFirestoreFunctions.deletcartItem(
        ref, widget.itemName, widget.cartCollection);
    Navigator.pop(context);
  }

  Future<void> increaseCartQuantity() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    await firebaseFirestoreFunctions.incrementProductQuantity(
        widget.cartCollection, widget.itemName, ref);
    Navigator.pop(context);
  }

  Future<void> decreaseCartQuantity() async {
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        });
    await firebaseFirestoreFunctions.decrementProductQuantity(
        ref, widget.cartCollection, widget.itemName);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    setWishlistState();
  }

  @override
  void dispose() {
    super.dispose();
    ref.read(mountedProvider.notifier).state =
        false; // Mark the widget as disposed
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: SizedBox(
          height: 300.h,
          child: PageView.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.images[index],
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Utilities.secondaryColor2,
                    highlightColor: Utilities.backgroundColor,
                    child: Container(
                      // width: 180.w,
                      color: Utilities.secondaryColor,
                    ),
                  ),
                );
              }),
        )),
        Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                height: 300.h,
                decoration: BoxDecoration(
                    border: widget.index == 0
                        ? Border.all()
                        : const Border(
                            top: BorderSide.none,
                            left: BorderSide(),
                            right: BorderSide(),
                            bottom: BorderSide(),
                          )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await updateWishlist();
                              },
                              child: Icon(isBookmarked
                                  ? FluentSystemIcons.ic_fluent_bookmark_filled
                                  : FluentSystemIcons
                                      .ic_fluent_bookmark_regular),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await deletcartItem();
                              },
                              child: const Icon(
                                  FluentSystemIcons.ic_fluent_dismiss_regular),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          widget.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${widget.price} USD',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed('measurmentsScreen');
                          },
                          child: Text(
                            'See measurement info',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Utilities.secondaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: Utilities.secondaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 30.h,
                          width: 30.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 6.h),
                          decoration: BoxDecoration(border: Border.all()),
                          child: GestureDetector(
                            onTap: () async {
                              await decreaseCartQuantity();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/minus (3).svg',
                              width: 15.w,
                            ),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 30.h,
                          width: 30.w,
                          // padding: EdgeInsets.symmetric(
                          //     horizontal: 6.w, vertical: 6.h),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(),
                              bottom: BorderSide(),
                            ),
                          ),
                          child: Text(
                            '${widget.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w400),
                          ),
                        ),
                        Container(
                          height: 30.h,
                          width: 30.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 6.h),
                          decoration: BoxDecoration(border: Border.all()),
                          child: GestureDetector(
                            onTap: () async {
                              await increaseCartQuantity();
                            },
                            child: SvgPicture.asset(
                              'assets/icons/plus.svg',
                              width: 15.w,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )))
      ],
    );
  }
}
