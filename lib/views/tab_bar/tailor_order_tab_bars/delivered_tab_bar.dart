import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/models/firebase_models/order_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_orders/future_or_stream_widget.dart/tailor_orders_stream_widget.dart';

class DeliveredTabBar extends StatelessWidget {
  DeliveredTabBar({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<OrderModel>> getOrderItemsStream() async* {
    // Fetch documents in 'users_orders' collection
    QuerySnapshot usersOrdersSnapshot =
        await FirebaseFirestore.instance.collection('users_orders').get();

    List<OrderModel> allOrders = [];

    // Loop through each document in 'users_orders'
    for (var parentDoc in usersOrdersSnapshot.docs) {
      // Stream from 'user_orders' sub-collection filtered by 'id'
      var userOrdersStream = FirebaseFirestore.instance
          .collection('users_orders')
          .doc(parentDoc.id)
          .collection('user_orders')
          .where('tailor_id', isEqualTo: getCurrentUserId())
          .where('order_status', isEqualTo: 'delivered')
          .snapshots();

      await for (var snapshot in userOrdersStream) {
        // Convert documents to OrderModel and add to the list
        var orders = snapshot.docs
            .map((doc) => OrderModel.fromDocument(doc.data()))
            .toList();
        allOrders.addAll(orders);
        yield allOrders; // Emit the combined list of orders
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TailorOrdersStreamWidget(getOrderItemsStream: getOrderItemsStream())
      ],
    );
  }
}
