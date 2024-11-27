import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitches_africa/constants/utilities.dart';

//SIGN IN/ SIGN UP

class Button extends StatelessWidget {
  final String text;
  final Color? color;
  final bool border;
  final double? paddingWidth;
  final double? paddingTop;
  final double? fontSize;
  final Function()? onTap;

  const Button(
      {super.key,
      this.color,
      required this.border,
      required this.text,
      this.paddingWidth,
      required this.onTap,
      this.paddingTop,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: paddingWidth ?? 15.w, vertical: paddingTop ?? 9.h),
        decoration: BoxDecoration(
            color:
                border ? Colors.transparent : color ?? Utilities.primaryColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
                color: color ?? Utilities.primaryColor, width: border ? 1 : 0)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Montserrat',
              color: border ? color ?? Utilities.primaryColor : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: fontSize ?? 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class ButtonIcon extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color? color;
  final bool border;
  final double? sizedBoxWidth;
  final double? paddingWidth;
  final double? paddingTop;
  final double? fontSize;
  final Function()? onTap;
  const ButtonIcon(
      {super.key,
      required this.text,
      required this.iconPath,
      this.color,
      required this.border,
      this.paddingWidth,
      this.paddingTop,
      this.fontSize,
      this.onTap,
      this.sizedBoxWidth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: paddingWidth ?? 15.w, vertical: paddingTop ?? 10.h),
        decoration: BoxDecoration(
            color:
                border ? Colors.transparent : color ?? Utilities.primaryColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
                color: color ?? Utilities.primaryColor, width: border ? 1 : 0)),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 20.h,
            ),
            SizedBox(width: sizedBoxWidth ?? 73.w),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Montserrat',
                color: border ? color ?? Utilities.primaryColor : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: fontSize ?? 14.sp,
              ),
            ),
            const Text('')
          ],
        ),
      ),
    );
  }
}

class ButtonIconOnly extends StatelessWidget {
  final String iconPath;
  final Color? color;
  final bool border;
  final double? paddingWidth;
  final double? paddingTop;
  final Function()? onTap;

  const ButtonIconOnly({
    super.key,
    this.color,
    required this.border,
    required this.iconPath,
    this.paddingWidth,
    required this.onTap,
    this.paddingTop,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: paddingWidth ?? 15.w, vertical: paddingTop ?? 10.h),
        decoration: BoxDecoration(
            color:
                border ? Colors.transparent : color ?? Utilities.primaryColor,
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
                color: color ?? Utilities.primaryColor, width: border ? 1 : 0)),
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            height: 20.h,
          ),
        ),
      ),
    );
  }
}

class Button2 extends StatelessWidget {
  final String text;
  final Color color;
  final Function()? onTap;
  const Button2(
      {super.key, required this.text, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 13.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.bold,
            color: Utilities.backgroundColor,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
