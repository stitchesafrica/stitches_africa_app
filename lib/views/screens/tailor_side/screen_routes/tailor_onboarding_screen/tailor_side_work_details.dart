import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_works/tailor_side_panel_widget.dart';

class TailorSideWorkDetails extends StatelessWidget {
  final List<String> images;
  final String title;
  final double price;
  const TailorSideWorkDetails(
      {super.key,
      required this.images,
      required this.title,
      required this.price});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // actions: [
          //   SvgPicture.asset(
          //     'assets/icons/bag.svg',
          //     height: 22.h,
          //   ),
          //   SizedBox(
          //     width: 8.w,
          //   ),
          // ],
        ),
        body: SlidingUpPanel(
          minHeight: MediaQuery.of(context).size.height * 0.2,
          maxHeight: MediaQuery.of(context).size.height,
          body: PageView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: images[index],
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
          panelBuilder: (controller) => TailorSidePanelWidget(
            controller: controller,
            images: images,
            title: title,
            price: price,
          ),
        ));
  }
}
