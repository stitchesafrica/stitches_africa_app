// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/tailor_shop/edit_work.dart';
import 'package:toastification/toastification.dart';

class TailorSideWorksWidget extends ConsumerWidget {
  final List<String> imagePath;
  final String title;
  final double price;
  final String productId;
  TailorSideWorksWidget(
      {super.key,
      required this.imagePath,
      required this.title,
      required this.price,
      required this.productId});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification showToasitification = ShowToasitification();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 0),
            width: 180.w,
            // height: 300.h,

            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: imagePath.first,
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
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: 180.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: 3.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '$price USD',
                        style: TextStyle(
                            fontSize: 12.sp, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.backgroundColor));
                          });
                      final data = await firebaseFirestoreFunctions
                          .getTailorWork(productId);
                      Navigator.pop(context);
                      if (data != null) {
                        ref.read(tagsProvider.notifier).state =
                            List<String>.from(data['tags']);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EditWork(data: data);
                        }));
                      } else {
                        showToasitification.showToast(
                            context: context,
                            toastificationType: ToastificationType.error,
                            title: 'Error retrieving data');
                      }
                    },
                    child: const Icon(
                      FluentSystemIcons.ic_fluent_edit_regular,
                      size: 20,
                    ),
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  GestureDetector(
                    onTap: () async {
                      await firebaseFirestoreFunctions
                          .deleteTailorWork(productId)
                          .then((_) {});
                      showToasitification.showToast(
                          context: context,
                          toastificationType: ToastificationType.success,
                          title: 'Work Deleted');
                    },
                    child: const Icon(
                      FluentSystemIcons.ic_fluent_dismiss_regular,
                      color: Utilities.delete,
                      size: 20,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
