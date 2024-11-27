import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/address_providers.dart';
import 'package:stitches_africa/config/providers/firebase_providers/cart_providers/cart_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/address_stream.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/authorize_payment_address_stream.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/future_or_stream_widgets/authorize_payment_items_stream_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/shopping_bag/shopping_panel_widget.dart';

class AuthorizePaymentScreen extends ConsumerWidget {
  final double deliveryFee;
  final String deliveryDate;
  final Stream<List<CartModel>> getCartItemsStream;
  final Stream<List<AddressModel>> getUserAddresses;
  const AuthorizePaymentScreen(
      {super.key,
      required this.deliveryFee,
      required this.deliveryDate,
      required this.getCartItemsStream,
      required this.getUserAddresses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddress = ref.watch(selectedAddressProvider);
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
              FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
            ),
          ),
        ),
      ),
      body: SlidingUpPanel(
        minHeight: MediaQuery.of(context).size.height * 0.15,
        maxHeight: MediaQuery.of(context).size.height * 0.25,
        onPanelOpened: () =>
            ref.read(onPanelOpenedProvider.notifier).state = true,
        onPanelClosed: () =>
            ref.read(onPanelOpenedProvider.notifier).state = false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                ),
                child: Text(
                  deliveryDate.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              AuthorizePaymentItemsStreamWidget(
                getCartItemsStream: getCartItemsStream,
              ),
              const Divider(
                thickness: 0.5,
                height: 0,
                color: Utilities.primaryColor,
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                ),
                child: Text(
                  'STANDARD DELIVERY',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 4.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15.w,
                ),
                child: Text(
                  'Delivery $deliveryDate',
                  style: TextStyle(
                    fontSize: 14.spMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              const Divider(
                thickness: 0.5,
                height: 0,
                color: Utilities.primaryColor,
              ),
              SizedBox(
                height: 20.h,
              ),
              if (selectedAddress != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedAddress.firstName} ${selectedAddress.lastName}'
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Text(
                            selectedAddress.streetAddress,
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          selectedAddress.flatNumber != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      selectedAddress.flatNumber!,
                                      style: TextStyle(
                                        fontSize: 14.spMin,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            '${selectedAddress.postcode}, ${selectedAddress.city}',
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            selectedAddress.country,
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            '${selectedAddress.dialCode} ${selectedAddress.phoneNumber}',
                            style: TextStyle(
                              fontSize: 14.spMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      AddressStrem2(getUserAddressesStream: getUserAddresses)
                    ],
                  ),
                )
              else
                AuthorizePaymentAddressStream(
                    getUserAddressesStream: getUserAddresses),
              SizedBox(
                height: 20.h,
              ),
              const Divider(
                thickness: 0.5,
                height: 0,
                color: Utilities.primaryColor,
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/paystack.svg',
                          height: 20.h,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          'PAYSTACK',
                          style: TextStyle(
                              fontSize: 14.spMin, fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                    const Icon(
                      FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              const Divider(
                thickness: 0.5,
                height: 0,
                color: Utilities.primaryColor,
              ),
            ],
          ),
        ),
        panelBuilder: (controller) => ShoppingPanelWidget(
          controller: controller,
          deliveryDate: deliveryDate,
          userAddress: selectedAddress?.toMap(),
          shippingCost: deliveryFee,
        ),
      ),
    );
  }
}
