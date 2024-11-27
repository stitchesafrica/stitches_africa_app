import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class HeightScreen extends ConsumerStatefulWidget {
  const HeightScreen({super.key});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  final TextEditingController heightController =
      TextEditingController(text: 150.toString());
  // Error variables
  String? heightError;

  bool _validateFields() {
    setState(() {
      // Reset error texts
      heightError =
          heightController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return heightError == null;
  }

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

  void _showCupertinoPicker({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required int minValue,
    required int maxValue,
    required bool isDouble,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300.h,
        color: Utilities.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 240.h,
              child: CupertinoPicker(
                backgroundColor: Utilities.backgroundColor,
                itemExtent: 32.h,
                onSelectedItemChanged: (index) {
                  setState(() {
                    if (isDouble) {
                      controller.text =
                          (minValue + (index * 1)).toStringAsFixed(1);
                    } else {
                      controller.text = (minValue + index).toString();
                      ref.read(heightProvider.notifier).state =
                          (minValue + index);
                    }
                  });
                },
                children: List<Widget>.generate(
                  (maxValue - minValue + 1),
                  (index) => Text(
                    isDouble
                        ? (minValue + (index * 1)).toStringAsFixed(1)
                        : (minValue + index).toString(),
                  ),
                ),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Utilities.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('HOW TALL ARE YOU?'),
        SizedBox(
          height: 10.h,
        ),
        Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
                border: Border.all(
              color: Utilities.primaryColor,
            )),
            child: Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showCupertinoPicker(
                      context: context,
                      title: 'Select Height',
                      controller: heightController,
                      minValue: 150,
                      maxValue: 220,
                      isDouble: false,
                    );
                  },
                  child: AbsorbPointer(
                    child: MyTextField(
                      controller: heightController,
                      hintText: '',
                      obscureText: false,
                      errorText: heightError,
                      enabledBorderColor: Utilities.backgroundColor,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Text(
                'CM',
                style:
                    TextStyle(fontSize: 14.sp, color: Utilities.secondaryColor),
              )
            ]))
      ],
    );
  }
}
