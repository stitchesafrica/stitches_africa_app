import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailors/tailor_list.dart';
import 'package:stitches_africa/views/widgets/user_side/tailors/trusted_tailors_widget.dart';

class MenTailorsTabBar extends StatelessWidget {
  const MenTailorsTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TAILORS A-Z',
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Yomi Casual, Kdove Couture, Deji & Kola and many more...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Utilities.secondaryColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const TailorList(category: 'men');
                  }));
                },
                child: const Icon(
                  FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 75.w,
                child: const Divider(
                  thickness: 0.5,
                  color: Utilities.secondaryColor2,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          Text(
            'Your trusted bespoke tailors',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Yomi Causal'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Kdove Couture'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Deji & Kola'),
          SizedBox(
            height: 20.h,
          ),
          Text(
            'Popular Tailors',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Yomi Causal'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Kdove Couture'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Deji & Kola'),
        ],
      ),
    );
  }
}
