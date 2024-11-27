import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';

class SearchTextField extends ConsumerWidget {
  final TextEditingController searchTextController;
  final FocusNode? focusNode; // Add FocusNode
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;

  const SearchTextField({
    super.key,
    required this.searchTextController,
    this.focusNode, // Add FocusNode
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoSearchTextField(
      focusNode: focusNode, // Attach FocusNode
      backgroundColor: Utilities.secondaryColor2,
      borderRadius: BorderRadius.circular(0),
      controller: searchTextController,
      onChanged: onChanged,
      onSuffixTap: () {
        searchTextController.clear();
      },
      onSubmitted: onSubmitted,
      onTap: () {
        ref.read(onChangedSearchProvider.notifier).state = '';
      },
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      placeholder: hintText,
      placeholderStyle: TextStyle(
        
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Utilities.secondaryColor,
      ),
      prefixIcon: SvgPicture.asset(
        'assets/icons/search.svg',
        color: Utilities.secondaryColor3,
        height: 18.h,
      ),
      suffixIcon: const Icon(
        FluentSystemIcons.ic_fluent_dismiss_circle_regular,
        color: Utilities.secondaryColor3,
      ),
    );
  }
}
