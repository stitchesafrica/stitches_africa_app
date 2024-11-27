import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/tab_bar/orders_and_returns_tab_bar/active_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/orders_and_returns_tab_bar/history_tab_bar.dart';

class OrdersAndReturnsTabBar extends StatelessWidget {
  const OrdersAndReturnsTabBar({super.key});

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
            onTap: (index) {
              // ref.read(searchTabBarIndexProvider.notifier).state = index;
            },
            tabs: const [
              Text(
                'ACTIVE',
              ),
              Text(
                'HISTORY',
              ),
            ]),
        SizedBox(
          height: 25.h,
        ),
        const Expanded(
          child: TabBarView(
            children: [
              ActiveTabBar(),
              HistoryTabBar(),
            ],
          ),
        ),
      ],
    );
  }
}
