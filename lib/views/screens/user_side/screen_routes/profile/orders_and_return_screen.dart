import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/user_side/profile/orders_and_returns/tab_bar/orders_and_returns_tab_bar.dart';

class OrdersAndReturnScreen extends ConsumerWidget {
  OrdersAndReturnScreen({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
            ),
          ),
        ),
        title: Text(
          'Orders and returns',
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              await firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);
              Navigator.pop(context);
              context.pushNamed('shoppingScreen');
            },
            child: SvgPicture.asset(
              'assets/icons/bag.svg',
              height: 22.h,
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                const Expanded(child: OrdersAndReturnsTabBar())
              ],
            ),
          )),
    );
  }
}
