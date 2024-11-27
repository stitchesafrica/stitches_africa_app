import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/order_model.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/user_orders/order_details.dart';

import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/orders_and_returns/tab_bar/order_items_widget.dart';

class ActiveTabBar extends StatelessWidget {
  const ActiveTabBar({super.key});

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<OrderModel>> getActiveOrderItems() {
    return FirebaseFirestore.instance
        .collection('users_orders')
        .doc(getCurrentUserId())
        .collection('user_orders')
        .where('order_status', isNotEqualTo: 'delivered')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromDocument(doc.data()))
            .toList());
  }

  String formatDate(DateTime timestamp) {
    return DateFormat('dd/MM/yy').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      StreamBuilder<List<OrderModel>>(
        stream: getActiveOrderItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No orders yet',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }

          final orderedItems = snapshot.data!;

          // Group orders by formatted date
          final groupedOrders = <String, List<OrderModel>>{};
          for (var order in orderedItems) {
            final dateKey = formatDate(order.timestamp);
            if (groupedOrders.containsKey(dateKey)) {
              groupedOrders[dateKey]!.add(order);
            } else {
              groupedOrders[dateKey] = [order];
            }
          }

          // Build the UI
          return Expanded(
            child: ListView.builder(
              itemCount: groupedOrders.keys.length,
              itemBuilder: (context, index) {
                final dateKey = groupedOrders.keys.elementAt(index);
                final ordersForDate = groupedOrders[dateKey]!;
                int totalItems = 0;
                double ordersTotalPrice = 0.0;
                for (var order in groupedOrders[dateKey]!) {
                  totalItems += order.quantity;
                }
                for (var order in groupedOrders[dateKey]!) {
                  ordersTotalPrice += order.price * order.quantity;
                }

                return OrderItemsWidget(
                  date: dateKey,
                  orderId: ordersForDate.first.orderId,
                  ordersTotalPrice: ordersTotalPrice,
                  totalItems: totalItems,
                  orderItems: ordersForDate,
                );
              },
            ),
          );
        },
      ),
    ]);
  }
}
