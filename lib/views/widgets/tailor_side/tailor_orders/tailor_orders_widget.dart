import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/pop_up_menu.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/address/see_user_address.dart';

class TailorOrdersWidget extends ConsumerStatefulWidget {
  final String orderId;
  final String tailorId;
  final String userId;
  final String productId;
  final String title;
  final String orderStatus;
  final String deliveryDate;
  final double price;
  final int quantity;
  final int index;
  final DateTime orderedDate;
  final List<String> images;
  final Map<String, dynamic> userAddressData;
  const TailorOrdersWidget({
    super.key,
    required this.orderId,
    required this.tailorId,
    required this.userId,
    required this.productId,
    required this.title,
    required this.orderStatus,
    required this.deliveryDate,
    required this.price,
    required this.quantity,
    required this.index,
    required this.orderedDate,
    required this.images,
    required this.userAddressData,
  });

  @override
  ConsumerState<TailorOrdersWidget> createState() => _TailorOrdersWidgetState();
}

class _TailorOrdersWidgetState extends ConsumerState<TailorOrdersWidget> {
  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String formatDate() {
    String formattedDate = DateFormat('dd-MM-yyyy').format(widget.orderedDate);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    final String selectedStatusValue = widget.orderStatus;

    return Row(
      children: [
        Expanded(
            child: SizedBox(
          height: 300.h,
          child: PageView.builder(
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.images[index],
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Utilities.secondaryColor2,
                    highlightColor: Utilities.backgroundColor,
                    child: Container(
                      // width: 180.w,
                      color: Utilities.secondaryColor,
                    ),
                  ),
                );
              }),
        )),
        Expanded(
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                height: 300.h,
                decoration: BoxDecoration(
                    border: widget.index == 0
                        ? Border.all()
                        : const Border(
                            top: BorderSide.none,
                            left: BorderSide(),
                            right: BorderSide(),
                            bottom: BorderSide(),
                          )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 2.5.h),
                              decoration: BoxDecoration(
                                color: Utilities.backgroundColor,
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: Text(
                                widget.orderStatus,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Utilities.primaryColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 0.w,
                            ),
                            PopUpMenu(
                              selectedStatusValue: selectedStatusValue,
                              userId: widget.userId,
                              productId: widget.productId,
                              tailorId: widget.tailorId,
                            ),
                          ],
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 0.h,
                        ),
                        Text(
                          'Order #${widget.orderId}',
                          style: TextStyle(
                            fontSize: 14.spMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed('measurmentsScreen');
                          },
                          child: Text(
                            'See measurement info',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Utilities.secondaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: Utilities.secondaryColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 4.h,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SeeUserAddress(
                                  userAddressData: widget.userAddressData);
                            }));
                          },
                          child: Text(
                            'See address info',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Utilities.secondaryColor,
                              decoration: TextDecoration.underline,
                              decorationColor: Utilities.secondaryColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          'Placed on: ${formatDate()}',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: Utilities.secondaryColor),
                        ),
                        SizedBox(
                          height: 3.h,
                        ),
                        Text(
                          'Est. delivery: ${widget.deliveryDate}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                    Text('Quantity: ${widget.quantity}',
                        style: TextStyle(
                          fontSize: 14.spMin,
                          fontWeight: FontWeight.w400,
                        )),
                  ],
                )))
      ],
    );
  }
}
