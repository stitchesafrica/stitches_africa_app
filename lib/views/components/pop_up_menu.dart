import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/tailor_order_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/api_service/notifications/one_signal_api.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class PopUpMenu extends ConsumerWidget {
  final String selectedStatusValue;
  final String userId;
  final String productId;
  final String tailorId;
  PopUpMenu(
      {super.key,
      required this.selectedStatusValue,
      required this.userId,
      required this.productId,
      required this.tailorId});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final OneSignalApi _oneSignalApi = OneSignalApi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
        color: Utilities.backgroundColor,
        surfaceTintColor: Utilities.backgroundColor,
        icon: const Icon(
          FluentSystemIcons.ic_fluent_chevron_down_filled,
          size: 18,
        ),
        onSelected: (value) async {
          await firebaseFirestoreFunctions.updateOrderStatus(
              value, userId, productId, tailorId);
          await _oneSignalApi.sendOrderStatusNotification(userId, value);
          await firebaseFirestoreFunctions.refreshTailorOrders(ref, tailorId);
          ref.read(orderStatusProvider.notifier).state =
              !ref.read(orderStatusProvider);
        },
        itemBuilder: ((context) {
          return [
            PopupMenuItem(
              value: 'pending',
              child: _buildPopupMenuItem('Pending'),
            ),
            PopupMenuItem(
              value: 'confirmed',
              child: _buildPopupMenuItem('Confirmed'),
            ),
            PopupMenuItem(
              value: 'processing',
              child: _buildPopupMenuItem('Processing'),
            ),
            PopupMenuItem(
              value: 'shipped',
              child: _buildPopupMenuItem('Shipped'),
            ),
            PopupMenuItem(
              value: 'delivered',
              child: _buildPopupMenuItem('Delivered'),
            ),
            PopupMenuItem(
              value: 'cancelled',
              child: _buildPopupMenuItem('Cancelled'),
            ),
            PopupMenuItem(
              value: 'returned',
              child: _buildPopupMenuItem('Returned'),
            ),
          ];
        }));
  }

  Widget _buildPopupMenuItem(String status) {
    Color getBackgroundColor(String value) {
      final Color backgroundColor;
      backgroundColor = value == selectedStatusValue
          ? Utilities.primaryColor
          : Utilities.backgroundColor;
      return backgroundColor;
    }

    Color getTextColor(String value) {
      final Color textColor;
      textColor = value == selectedStatusValue
          ? Utilities.backgroundColor
          : Utilities.primaryColor;
      return textColor;
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: getBackgroundColor(status.toLowerCase()),
        borderRadius: BorderRadius.circular(0.r),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: getTextColor(status.toLowerCase()),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
