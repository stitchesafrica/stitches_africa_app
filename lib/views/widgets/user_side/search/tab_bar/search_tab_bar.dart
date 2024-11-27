import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/tab_bar/search_tab_bars/kids_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/search_tab_bars/men_tab_bar.dart';
import 'package:stitches_africa/views/tab_bar/search_tab_bars/women_tab_bar.dart';

class SearchTabBar extends ConsumerWidget {
  const SearchTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<String> list = [
      'Traditional Wears',
      'Ankara Wears',
      'Bubu Wears',
      'Traditional Wears',
      'Ankara Wears',
      'Bubu Wears',
      'Traditional Wears',
      'Ankara Wears',
      'Bubu Wears',
      'Traditional Wears',
      'Ankara Wears',
      'Bubu Wears',
    ];
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
              ref.read(searchTabBarIndexProvider.notifier).state = index;
            },
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
              WomenTabBar(
                list: list,
              ),
              MenTabBar(
                list: list,
              ),
              KidsTabBar(
                list: list,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
