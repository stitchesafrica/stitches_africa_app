// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';

class ShoppingPreferenceWidget extends StatefulWidget {
  const ShoppingPreferenceWidget({super.key});

  @override
  State<ShoppingPreferenceWidget> createState() =>
      _ShoppingPreferenceWidgetState();
}

class _ShoppingPreferenceWidgetState extends State<ShoppingPreferenceWidget> {
  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  String? selectedPreference;

  @override
  void initState() {
    super.initState();
    // Get initial shopping preference from Hive
    var box = Hive.box('user_preferences');
    final user = box.get('user');
    selectedPreference = user['shoppingPreference'];
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  void _showConfrimationDialog(BuildContext context, String preference) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Change your settings',
            content:
                'Switching to the ${preference.toLowerCase()}\'s shop will reload the app.\nDo you want to contiue?',
            button1Text: 'Cancel',
            button2Text: 'OK',
            onButton1Pressed: () => Navigator.pop(context),
            onButton2Pressed: () async {
              setState(() {
                selectedPreference = preference;
              });

              await firebaseFirestoreFunctions.updateShoppingPrefrence(
                  getCurrentUserId(), preference);
              //restart the app
              Phoenix.rebirth(context);
              Navigator.pop(context);
            },
          );
        },
      );
    } else {
      // Material AlertDialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Change your settings',
            content:
                'Switching to the ${preference.toLowerCase()}\'s shop will reload the app.\nDo you want to contiue?',
            button1Text: 'Cancel',
            button2Text: 'OK',
            button1BorderEnabled: true,
            button2BorderEnabled: false,
            onButton1Pressed: () => Navigator.pop(context),
            onButton2Pressed: () async {
              setState(() {
                selectedPreference = preference;
              });

              await firebaseFirestoreFunctions.updateShoppingPrefrence(
                  getCurrentUserId(), preference);
              //restart the app
              Phoenix.rebirth(context);
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  void _updatePreference(String preference) {
    _showConfrimationDialog(context, preference);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          title: Text(
            "Women",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Radio<String>(
            value: "Women",
            visualDensity: VisualDensity.compact,
            activeColor: Utilities.primaryColor,
            groupValue: selectedPreference,
            onChanged: (value) {
              _updatePreference(value!);
            },
          ),
        ),
        SizedBox(
          height: 0.h,
        ),
        SizedBox(
          width: 75.w,
          child: const Divider(
            thickness: 0.5,
            color: Utilities.secondaryColor2,
          ),
        ),
        SizedBox(
          height: 0.h,
        ),
        ListTile(
          title: Text(
            "Men",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Radio<String>(
            value: "Men",
            visualDensity: VisualDensity.compact,
            activeColor: Utilities.primaryColor,
            groupValue: selectedPreference,
            onChanged: (value) async {
              _updatePreference(value!);
            },
          ),
        ),
        SizedBox(
          height: 0.h,
        ),
        SizedBox(
          width: 75.w,
          child: const Divider(
            thickness: 0.5,
            color: Utilities.secondaryColor2,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
      ],
    );
  }
}
