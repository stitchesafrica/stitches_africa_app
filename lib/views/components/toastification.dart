import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

class ShowToasitification {
  ToastificationItem showToast({
    required BuildContext context,
    required ToastificationType toastificationType,
    required String title,
  }) {
    return toastification.show(
      context: context,
      type: toastificationType,
      style: ToastificationStyle.flat,
      title: Text(title),
      autoCloseDuration: const Duration(seconds: 2),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(0),
    );
  }
}
