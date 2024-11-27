import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';

class TrustedTailorsWidget extends StatelessWidget {
  final String tailorName;
  const TrustedTailorsWidget({super.key, required this.tailorName});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: 85.h,
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            decoration: BoxDecoration(
                border: Border.all(
              color: Utilities.primaryColor,
            )),
            child: Row(
              children: [
                const Icon(FluentSystemIcons.ic_fluent_heart_regular),
                SizedBox(
                  width: 10.w,
                ),
                Text(
                  tailorName,
                )
              ],
            ),
          ),
          Image.asset('assets/images/ob_1.png')
        ],
      ),
    );
  }
}
