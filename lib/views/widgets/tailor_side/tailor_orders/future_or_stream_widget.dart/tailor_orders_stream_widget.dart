// ignore_for_file: unused_import

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/models/firebase_models/order_model.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_orders/tailor_orders_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/shopping_items_widget.dart';

class TailorOrdersStreamWidget extends StatelessWidget {
  final Stream<List<OrderModel>> getOrderItemsStream;

  const TailorOrdersStreamWidget(
      {super.key, required this.getOrderItemsStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
        stream: getOrderItemsStream,
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
              'You have no orders yet',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final orderData = snapshot.data!;
          return Expanded(
              child: ListView.builder(
                  itemCount: orderData.length,
                  itemBuilder: (context, index) {
                    final orderItem = orderData[index];
                    return TailorOrdersWidget(
                      orderId: orderItem.orderId,
                      tailorId: orderItem.tailorId,
                      userId: orderItem.userId,
                      productId: orderItem.productId,
                      title: orderItem.title,
                      orderStatus: orderItem.orderStatus,
                      deliveryDate: orderItem.deliveryDate,
                      price: orderItem.price,
                      quantity: orderItem.quantity,
                      index: index,
                      orderedDate: orderItem.timestamp,
                      images: orderItem.images,
                      userAddressData: orderItem.userAddress,
                    );
                  }));
        });
  }
}
