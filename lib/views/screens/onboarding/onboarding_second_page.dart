import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/glassbox.dart';

class OnBoardingSecondPage extends StatelessWidget {
  const OnBoardingSecondPage({super.key});

  Future<void> initializeOneSignal() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize('6a1b03c9-c01b-4713-8e65-d50088059721');

    await OneSignal.Notifications.requestPermission(true);
  }

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage('assets/images/ob_3.png'),
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
                      height: 45.h,
                    ),
                    Text(
                      'BE THE FIRST TO\nTAILOR YOUR STYLE',
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
                    SizedBox(
                      width: 330.w,
                      child: const Text(
                        'Allow notifications for bespoke new arrivals, exciting launches, and promotions.',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                           letterSpacing: 0.5,
                        ),
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
                              text: 'Not now',
                              onTap: () {
                                context.goNamed('guest');
                              }),
                        ),
                        SizedBox(
                          width: 150.w,
                          height: 50.h,
                          child: Button(
                              fontSize: 14.sp,
                              border: false,
                              text: 'Notify Me',
                              onTap: () async {
                                await initializeOneSignal().then((_) {
                                  context.goNamed('guest');
                                });
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
