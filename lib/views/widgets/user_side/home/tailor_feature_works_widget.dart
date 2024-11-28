import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_model_home_screen.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailor_wears_catalog_screen.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';

class TailorFeatureWorksWidget extends StatelessWidget {
  final TailorModelHomeScreen tailor;

  const TailorFeatureWorksWidget({super.key, required this.tailor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tailor's Profile Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CachedNetworkImage(
                  fit: BoxFit.cover,
                  height: 18.h,
                  imageUrl: tailor.tailorLogo,
                  placeholder: (context, url) => _buildShimmerPlaceholder(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                SizedBox(width: 10.w),
                Text(
                  tailor.tailorName,
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        /// Tailor's Motto
        Text(
          tailor.tailorMotto,
          style: TextStyle(
            fontSize: 14.spMin,
            color: Utilities.secondaryColor,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 20.h),

        /// Tailor's Works List
        SizedBox(
          height: 400.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tailor.works.length,
            itemBuilder: (context, index) {
              final workImageUrl = tailor.works[index];
              return _buildWorkItem(context, workImageUrl);
            },
          ),
        ),

        SizedBox(height: 20.h),

        /// Shop Now Button
        Button(
          border: true,
          text: 'Shop Now',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TailorWearsCatalogScreen(
                  docID: tailor.docID,
                  tailorName: tailor.tailorName,
                ),
              ),
            );
          },
        ),

        SizedBox(height: 50.h),
      ],
    );
  }

  /// Builds a shimmer placeholder for loading images
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Utilities.secondaryColor2,
      highlightColor: Utilities.backgroundColor,
      child: Container(
        color: Utilities.secondaryColor,
      ),
    );
  }

  /// Builds a single work item with a Hero animation
  Widget _buildWorkItem(BuildContext context, String imageUrl) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      width: 250.w,
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
            placeholder: (context, url) => _buildShimmerPlaceholder(),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }
}
