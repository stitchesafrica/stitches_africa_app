import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/address_stream.dart';

class ProfileWidget extends StatelessWidget {
  final String text;
  final Stream<List<AddressModel>>? getUserAddressesStream;
  final Function()? onTap;
  const ProfileWidget(
      {super.key, required this.text, this.onTap, this.getUserAddressesStream});

  @override
  Widget build(BuildContext context) {
    String _selectedOption = text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
            if (text == 'Women' || text == 'Men')
              Radio(
                  visualDensity: VisualDensity.compact,
                  activeColor: Utilities.primaryColor,
                  value: text,
                  groupValue: _selectedOption,
                  onChanged: (value) {})
            else
              text == 'Address book'
                  ? AddressStrem2(
                      getUserAddressesStream: getUserAddressesStream!,
                      size: 18,
                    )
                  : GestureDetector(
                      onTap: onTap,
                      child: const Icon(
                        FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                        size: 18,
                      ),
                    ),
          ],
        ),
        SizedBox(
          height: 10.h,
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
        )
      ],
    );
  }
}
