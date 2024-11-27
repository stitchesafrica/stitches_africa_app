import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';
import 'package:toastification/toastification.dart';

class TailorSideImagesWidget extends StatelessWidget {
  final String imageUrl;
  final String productId;
  TailorSideImagesWidget(
      {super.key, required this.imageUrl, required this.productId});
  final ShowToasitification showToasitification = ShowToasitification();
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10.w),
      child: Slidable(
        direction: Axis.vertical,
        endActionPane: ActionPane(
            extentRatio: 0.3,
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) async {
                  await firebaseFirestoreFunctions.removeImageFromWorks(
                      productId, imageUrl);
                  showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.success,
                    title: 'Image deleted',
                  );
                },
                backgroundColor: Utilities.delete,
                icon: FluentSystemIcons.ic_fluent_delete_filled,
              )
            ]),
        child: SizedBox(
          width: 150.w,
          height: 250.h,
          child: GestureDetector(
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
          ),
        ),
      ),
    );
  }
}
