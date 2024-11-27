import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/address/add_new_address.dart';
import 'package:stitches_africa/views/widgets/user_side/address/address_list_widget.dart';

class UserAddressList extends StatelessWidget {
  final List<AddressModel> addressModelData;
  const UserAddressList({super.key, required this.addressModelData});

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              FluentSystemIcons.ic_fluent_dismiss_regular,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Text(
              'SELECT A DELIVERY LOCATION',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.spMin,
                // letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: addressModelData.length,
                itemBuilder: (context, index) {
                  AddressModel addressData = addressModelData[index];
                  return AddressListWidget(
                    addressData: addressData,
                    index: index,
                    length: addressModelData.length,
                  );
                }),
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
          height: 40.h,
          elevation: 0,
          color: Utilities.backgroundColor,
          padding: EdgeInsets.zero,
          child: Button(
              border: true,
              text: 'Add New Home Address',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AddNewAddress(
                      didItComeFromCheckoutScreen: false);
                }));
              })),
    );
  }
}
