import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitches_africa/constants/utilities.dart';

class TailorSidePanelWidget extends StatelessWidget {
  final ScrollController controller;
  final List<String> images;
  final String title;
  final double price;
  const TailorSidePanelWidget(
      {super.key,
      required this.controller,
      required this.images,
      required this.title,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      children: [
        SvgPicture.asset(
          'assets/icons/minus.svg',
          height: 25.h,
          color: Utilities.primaryColor,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 0.h,
            ),
            Text(
              '$price USD',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        )
      ],
    );
  }
}
