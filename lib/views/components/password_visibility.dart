import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';

class PasswordVisibility extends StatelessWidget {
  final Widget child;
  final bool obscureText;
  const PasswordVisibility(
      {super.key, required this.child, required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        child,
        Icon(
          obscureText
              ? FluentSystemIcons.ic_fluent_eye_hide_filled
              : FluentSystemIcons.ic_fluent_eye_show_filled,
          color: Utilities.primaryColor,
          size: 22,
        )
      ],
    );
  }
}
