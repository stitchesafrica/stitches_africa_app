import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailors/tailor_list.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailors_list_wears_route.dart';
import 'package:stitches_africa/views/widgets/user_side/tailors/favorite_tailor_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/tailors/trusted_tailors_widget.dart';

class WomenTailorsTabBar extends StatelessWidget {
  WomenTailorsTabBar({super.key});

  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference favoriteCollection = FirebaseFirestore.instance
        .collection('users_favorite_tailors')
        .doc(getCurrentUserId())
        .collection('user_favorite_tailors');
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TAILORS A-Z',
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Yomi Casual, Kdove Couture, Deji & Kola and many more...',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Utilities.secondaryColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const TailorList(category: 'women');
                  }));
                },
                child: const Icon(
                  FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                  size: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 75.w,
                child: const Divider(
                  thickness: 0.5,
                  color: Utilities.secondaryColor2,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25.h,
          ),
          FutureBuilder(
            future: firebaseFirestoreFunctions
                .getUserFavoriteTailors(favoriteCollection),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return const SizedBox.shrink(); // No data, return empty
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your favorite tailors',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Column(
                        children: data.map<Widget>((tailor) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TailorsListWearsRoute(
                                  favoriteCollection: favoriteCollection,
                                  tailorId: tailor['id'],
                                  tailorName: tailor['brand_name'],
                                );
                              }));
                            },
                            child: FavoriteTailorWidget(
                              tailorName: tailor['brand_name'],
                              favoriteCollection: favoriteCollection,
                              tailorId: tailor['id'],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
              }
              return const SizedBox
                  .shrink(); // While loading, display a full screen loader or placeholder
            },
          ),
          Text(
            'Your trusted bespoke tailors',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Yomi Causal'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Kdove Couture'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Deji & Kola'),
          SizedBox(
            height: 20.h,
          ),
          Text(
            'Popular Tailors',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Yomi Causal'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Kdove Couture'),
          SizedBox(
            height: 10.h,
          ),
          const TrustedTailorsWidget(tailorName: 'Deji & Kola'),
        ],
      ),
    );
  }
}
