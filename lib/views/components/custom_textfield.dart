import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final bool obscureText;
  final int? maxLength;
  final double? fontSize;
  final bool? readOnly;
  final Color? enabledBorderColor;
  final String? errorText;
  final String? helperText;
  final TextInputType? textType;
  final TextInputAction? textAction;
  final double? paddingHeight;
  final double? paddingWidth;
  final List<String>? autofillHints;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText,
      this.focusNode,
      this.maxLength,
      this.fontSize,
      this.readOnly,
      this.enabledBorderColor,
      this.textType,
      this.textAction,
      this.paddingHeight,
      this.paddingWidth,
      this.autofillHints,
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.helperText});

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  void dispose() {
    if (widget.focusNode != null) {
      widget.focusNode!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Utilities.primaryColor,
      readOnly: widget.readOnly ?? false,
      focusNode: widget.focusNode,
      controller: widget.controller,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLength: widget.maxLength,
      keyboardType: widget.hintText == 'EMAIL'
          ? TextInputType.emailAddress
          : widget.textType,
      textInputAction: widget.textAction,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      autofillHints: widget.autofillHints,
      style: TextStyle(fontSize: widget.fontSize),
      decoration: InputDecoration(
          labelText: widget.hintText,
          errorText: widget.errorText,
          helper: widget.helperText != null
              ? Row(
                  children: [
                    const Icon(
                      FluentSystemIcons.ic_fluent_info_regular,
                      size: 12,
                      color: Utilities.secondaryColor,
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Text(
                      widget.helperText!,
                      style: TextStyle(
                          fontSize: 10.sp,
                          color: Utilities.secondaryColor,
                          fontWeight: FontWeight.w400),
                    )
                  ],
                )
              : null,
          contentPadding: const EdgeInsets.only(bottom: 0),
          labelStyle: TextStyle(
            color: Utilities.secondaryColor3,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          //floatingLabelBehavior: FloatingLabelBehavior.never,
          floatingLabelStyle: const TextStyle(
            color: Utilities.secondaryColor3,
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: widget.enabledBorderColor ?? Utilities.secondaryColor3,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(
              color: Utilities.secondaryColor3,
            ),
          )),
    );
  }
}

class MeasurementTextField extends StatelessWidget {
  final TextEditingController controller;

  final bool obscureText;
  final String? textType;
  final double? paddingHeight;
  final double? paddingWidth;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  const MeasurementTextField({
    super.key,
    required this.controller,
    required this.obscureText,
    this.textType,
    this.paddingHeight,
    this.paddingWidth,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
          labelText: '0.0',
          labelStyle: TextStyle(
            color: Utilities.primaryColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide.none,
          )),
    );
  }
}

class DescriptionTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final String? textType;
  final Function(String)? onChanged;
  const DescriptionTextField(
      {super.key,
      required this.controller,
      this.hintText,
      this.errorText,
      this.onChanged,
      this.textType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(
                width: 1, color: Utilities.primaryColor.withOpacity(0.267))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide:
                const BorderSide(width: 1, color: Utilities.secondaryColor)),
        errorText: errorText,
        labelText: hintText,
        labelStyle: TextStyle(
          color: Utilities.secondaryColor3,
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
        ),
        //border: OutlineInputBorder()
      ),
    );
  }
}
