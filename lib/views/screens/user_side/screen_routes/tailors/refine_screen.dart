import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';

class RefineScreen extends ConsumerStatefulWidget {
  const RefineScreen({super.key});

  @override
  ConsumerState<RefineScreen> createState() => _RefineScreenState();
}

class _RefineScreenState extends ConsumerState<RefineScreen> {
  @override
  Widget build(BuildContext context) {
    String groupValue = ref.watch(groupValueProvider);
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentSystemIcons.ic_fluent_dismiss_filled,
              size: 20, color: Utilities.primaryColor),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'Refine',
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ref.invalidate(groupValueProvider);
            },
            child: Text(
              "Clear all",
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w400,
                color: Utilities.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              "Sort by",
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 20.h),
          ..._buildSortOptions(context),
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
          SizedBox(height: 10.h),
          // const Text(
          //   "Filter by",
          //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          // ),
          // const SizedBox(height: 8),
          // ..._buildFilterOptions(context),
          // const Spacer(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
          border: false,
          text: 'Show Results',
          onTap: () {
            Navigator.pop(
              context,
              groupValue, // Pass the selected sorting option back to the previous screen
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSortOptions(BuildContext context) {
    String groupValue = ref.watch(groupValueProvider);
    final List<String> sortOptions = [
      "Price (low first)",
      "Price (high first)",
      "Discount (high first)",
    ];
    return sortOptions
        .map(
          (option) => ListTile(
            minLeadingWidth: 0,
            title: Text(
              option,
              style: TextStyle(
                fontSize: 16.spMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: Radio<String>(
              value: option,
              visualDensity: VisualDensity.compact,
              activeColor: Utilities.primaryColor,
              groupValue: groupValue,
              onChanged: (value) {
                ref.read(groupValueProvider.notifier).state = value!;
              },
            ),
          ),
        )
        .toList();
  }

  List<Widget> _buildFilterOptions(BuildContext context) {
    final List<String> filterOptions = [
      "Categories",
      "Brands",
      "Colors",
      "Sizes",
      "Price range",
      "Sale discount",
    ];
    return filterOptions
        .map(
          (filter) => ListTile(
            title: Text(filter),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to respective filter screen
            },
          ),
        )
        .toList();
  }
}
