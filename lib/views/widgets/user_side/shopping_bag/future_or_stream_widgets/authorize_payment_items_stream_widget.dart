import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';

class AuthorizePaymentItemsStreamWidget extends StatelessWidget {
  final Stream<List<CartModel>> getCartItemsStream;
  const AuthorizePaymentItemsStreamWidget(
      {super.key, required this.getCartItemsStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CartModel>>(
        stream: getCartItemsStream,
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
              'Your cart is empty',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final cartData = snapshot.data!;
          return Container(
              height: 230.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                    ),
                    child: Text(
                      '${cartData.length} items',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cartData.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: cartData[index].images.first,
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
                  ),
                ],
              ));
        });
  }
}
