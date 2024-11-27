import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/tab_bar/tailor_tab_bars/kids_tailors_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/tailor_tab_bars/men_tailors_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/tailor_tab_bars/women_tailors_tab_bar.dart';

class TailorTabBar extends StatelessWidget {
  const TailorTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
            dividerHeight: 0.1,
            isScrollable: true,
            indicatorWeight: 2,
            indicator:
                UnderlineTabIndicator(borderSide: BorderSide(width: 1.w)),
            indicatorColor: Utilities.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 15.w),
            labelStyle: TextStyle(
              color: Utilities.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              color: Utilities.primaryColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
            tabAlignment: TabAlignment.start,
            splashFactory: NoSplash.splashFactory,
            tabs: const [
              Text(
                'WOMEN',
              ),
              Text(
                'MEN',
              ),
              Text(
                'KIDS',
              ),
            ]),
        SizedBox(
          height: 25.h,
        ),
         Expanded(
          child: TabBarView(
            children: [
              WomenTailorsTabBar(),
              MenTailorsTabBar(),
              KidsTailorsTabBar(),
            ],
          ),
        ),
      ],
    );
  }
}
