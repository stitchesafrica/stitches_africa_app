import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/onboarding_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/hive_service/hive_service.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/glassbox.dart';

// ignore: must_be_immutable
class OnBoardingFirstPage extends ConsumerWidget {
  OnBoardingFirstPage({super.key});

  HiveService hiveService = HiveService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: 60.h, left: 125.w),
            height: 841.h,
            width: 631.w,
            decoration: const BoxDecoration(
              //color: Colors.red,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/ob_1.png'),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: SizedBox(
              height: 320.h,
              width: 400.w,
              child: GlassBox(
                  child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25.h,
                    ),
                    Text(
                      'WELCOME TO\nSTITCHES AFRICA',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    const Text(
                      'Discover the finest bespoke fashion from talented tailors. Enjoy a personalized experience, custom-made outfits, and exclusive offers just for you.',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                         letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: Button(
                              fontSize: 14.sp,
                              border: true,
                              text: 'Shop Women',
                              onTap: () {
                                ref
                                    .read(shoppingPreferenceProvider.notifier)
                                    .state = 'Women';
                                context.pushNamed('onboarding2');
                              }),
                        ),
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: Button(
                              fontSize: 14.sp,
                              border: true,
                              text: 'Shop Men',
                              onTap: () {
                                ref
                                    .read(shoppingPreferenceProvider.notifier)
                                    .state = 'Men';
                                context.pushNamed('onboarding2');
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
