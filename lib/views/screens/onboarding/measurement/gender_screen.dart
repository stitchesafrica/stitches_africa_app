import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';

class GenderScreen extends ConsumerWidget {
  const GenderScreen({super.key});

  /// Builds a label for input fields
  Widget _buildLabel(String label, {double? fontSize}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 14.sp,
        color: Utilities.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedGender = ref.watch(genderProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('HOW DO YOU IDENTIFY?'),
        SizedBox(
          height: 10.h,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
            color: Utilities.primaryColor,
          )),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(genderProvider.notifier).state = 'female';
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
                    decoration: BoxDecoration(
                      color: selectedGender == 'female'
                          ? Utilities.primaryColor
                          : Utilities.backgroundColor,
                    ),
                    child: Text(
                      'Female',
                      style: TextStyle(
                        color: selectedGender == 'female'
                            ? Utilities.backgroundColor
                            : Utilities.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(genderProvider.notifier).state = 'male';
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
                    decoration: BoxDecoration(
                      color: selectedGender == 'male'
                          ? Utilities.primaryColor
                          : Utilities.backgroundColor,
                    ),
                    child: Text(
                      'Male',
                      style: TextStyle(
                        color: selectedGender == 'male'
                            ? Utilities.backgroundColor
                            : Utilities.primaryColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
