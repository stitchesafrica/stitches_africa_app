import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class IOSAlertDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String actionButton1;
  final VoidCallback actionButton1OnTap;
  final bool isDefaultAction1;
  final bool isDestructiveAction1;
  final String? actionButton2;
  final VoidCallback? actionButton2OnTap;
  final bool? isDefaultAction2;
  final bool? isDestructiveAction2;
  const IOSAlertDialogWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.actionButton1,
      required this.actionButton1OnTap,
      required this.isDefaultAction1,
      required this.isDestructiveAction1,
      this.actionButton2,
      this.actionButton2OnTap,
      this.isDefaultAction2,
      this.isDestructiveAction2});

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (actionButton2 != null)
          CupertinoDialogAction(
            onPressed: actionButton2OnTap,
            isDefaultAction: isDefaultAction2!,
            isDestructiveAction: isDestructiveAction2!,
            child: Text(actionButton2!),
          ),
        CupertinoDialogAction(
          onPressed: actionButton1OnTap,
          isDefaultAction: isDefaultAction1,
          isDestructiveAction: isDestructiveAction1,
          child: Text(actionButton1),
        ),
      ],
    );
  }
}

class AndriodAleartDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String actionButton1;
  final VoidCallback actionButton1OnTap;
  final String? actionButton2;
  final VoidCallback? actionButton2OnTap;

  const AndriodAleartDialogWidget(
      {super.key,
      required this.title,
      required this.content,
      required this.actionButton1,
      required this.actionButton1OnTap,
      this.actionButton2,
      this.actionButton2OnTap});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        if (actionButton2 != null)
          TextButton(
            onPressed: actionButton2OnTap,
            child: Text(actionButton2!),
          ),
        TextButton(
          onPressed: actionButton1OnTap,
          child: Text(actionButton1),
        ),
      ],
    );
  }
}
