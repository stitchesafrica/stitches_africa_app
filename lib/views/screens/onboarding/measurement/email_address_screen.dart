import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class EmailAddressScreen extends StatelessWidget {
  EmailAddressScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

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
  Widget build(BuildContext context) {
    _emailController.text = FirebaseAuth.instance.currentUser!.email!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('EMAIL'),
        MyTextField(
          controller: _emailController,
          hintText: '',
          obscureText: false,
          textType: TextInputType.number,
        ),
        
      ],
    );
  }
}
