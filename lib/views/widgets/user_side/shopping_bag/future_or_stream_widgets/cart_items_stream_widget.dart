import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/shopping_items_widget.dart';

class CartItemsStreamWidget extends StatelessWidget {
  final Stream<List<CartModel>> getCartItemsStream;
  final CollectionReference wishlistSubCollection;
  final CollectionReference cartSubCollection;
  const CartItemsStreamWidget(
      {super.key,
      required this.wishlistSubCollection,
      required this.cartSubCollection,
      required this.getCartItemsStream});

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
          return Expanded(
              child: ListView.builder(
                  itemCount: cartData.length,
                  itemBuilder: (context, index) {
                    return ShoppingItemsWidget(
                      wishlistCollection: wishlistSubCollection,
                      cartCollection: cartSubCollection,
                      index: index,
                      id: cartData[index].id,
                      productId: cartData[index].productId,
                      images: cartData[index].images,
                      itemName: cartData[index].title,
                      price: cartData[index].price,
                      quantity: cartData[index].quantity,
                    );
                  }));
        });
  }
}
