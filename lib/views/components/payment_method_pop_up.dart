import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';

class PaymentMethodPopUp extends StatelessWidget {
  final String selectedPaymentMethod;
  const PaymentMethodPopUp({super.key, required this.selectedPaymentMethod});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        color: Utilities.backgroundColor,
        surfaceTintColor: Utilities.backgroundColor,
        icon: const Icon(
          FluentSystemIcons.ic_fluent_chevron_down_filled,
          size: 18,
        ),
        onSelected: (value) async {},
        itemBuilder: ((context) {
          return [
            PopupMenuItem(
              value: 'Online Bank',
              child: _buildPopupMenuItem('Online Bank'),
            ),
          ];
        }));
  }

  Widget _buildPopupMenuItem(String status) {
    Color getBackgroundColor(String value) {
      final Color backgroundColor;
      backgroundColor = value == selectedPaymentMethod
          ? Utilities.primaryColor
          : Utilities.backgroundColor;
      return backgroundColor;
    }

    Color getTextColor(String value) {
      final Color textColor;
      textColor = value == selectedPaymentMethod
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
