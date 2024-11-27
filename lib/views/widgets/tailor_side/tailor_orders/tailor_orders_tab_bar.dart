import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/tailor_order_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/tab_bar/tailor_order_tab_bars/tailor_side_active_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/tailor_order_tab_bars/delivered_tab_bar.dart';

class TailorOrdersTabBar extends ConsumerWidget {
  const TailorOrdersTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalOrders = ref.watch(totalOrderItemsProvider);
    final isorderStatusEdited = ref.watch(orderStatusProvider);
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
            tabs: [
              Text(
                'ACTIVE ($totalOrders)',
              ),
              const Text(
                'DELIVERED',
              ),
            ]),
        SizedBox(
          height: 25.h,
        ),
        Expanded(
          child: TabBarView(
            children: [
              TailorSideActiveTabBar(),
              DeliveredTabBar(),
            ],
          ),
        ),
      ],
    );
  }
}
