import 'dart:io';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/address/user_address_list.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';

import 'package:stitches_africa/constants/utilities.dart';

class AddressStream extends StatelessWidget {
  final Stream<List<AddressModel>> getUserAddressesStream;
  const AddressStream({
    super.key,
    required this.getUserAddressesStream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getUserAddressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          } else if (snapshot.hasError) {
            if (Platform.isIOS) {
              return IOSAlertDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  },
                  isDefaultAction1: true,
                  isDestructiveAction1: false);
            } else {
              return AndriodAleartDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  });
            }
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No address saved',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final addressData = snapshot.data!;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  addressData.first.streetAddress.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return UserAddressList(addressModelData: addressData);
                    }));
                  },
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class AddressStrem2 extends StatelessWidget {
  final Stream<List<AddressModel>> getUserAddressesStream;
  final double? size;
  const AddressStrem2(
      {super.key, required this.getUserAddressesStream, this.size});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: getUserAddressesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('...');
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No address saved',
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ));
          }
          final addressData = snapshot.data!;
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UserAddressList(addressModelData: addressData);
              }));
            },
            child: Icon(
              size: size,
              FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
            ),
          );
        });
  }
}
