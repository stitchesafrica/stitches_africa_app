import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/order_model.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/user_orders/order_details.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';

class OrderItemsWidget extends StatelessWidget {
  final String date;
  final String orderId;
  final double ordersTotalPrice;
  final int totalItems;
  final List<OrderModel> orderItems;
  const OrderItemsWidget(
      {super.key,
      required this.date,
      required this.orderId,
      required this.ordersTotalPrice,
      required this.totalItems,
      required this.orderItems});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Date',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  width: 10.w,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Reference',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      orderId,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return OrderDetails(
                    orderId: orderId,
                    date: date,
                    itemsLength: totalItems,
                    totalPrice: ordersTotalPrice,
                  );
                }));
              },
              child: const Icon(
                FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            //   physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            //shrinkWrap: true,
            itemCount: orderItems.length,
            itemBuilder: (context, orderIndex) {
              final order = orderItems[orderIndex];
              final imageUrl = order.images.first;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(imageUrl: imageUrl),
                    ),
                  );
                },
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Utilities.secondaryColor2,
                      highlightColor: Utilities.backgroundColor,
                      child: Container(
                        width: 180.w,
                        color: Utilities.secondaryColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 20.h,
        ),
      ],
    );
  }
}
