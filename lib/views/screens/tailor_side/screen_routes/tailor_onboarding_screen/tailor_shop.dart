import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/tailor_side_work_details.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_works/tailor_side_works_widget.dart';

class TailorShop extends ConsumerWidget {
  TailorShop({super.key});

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Stream<List<TailorWorkModel>> getTailorsWorksStream() {
    return FirebaseFirestore.instance
        .collection('tailor_works')
        .where('id', isEqualTo: getCurrentUserId())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorWorkModel.fromDocument(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10.h,
            ),
            Expanded(
                child: StreamBuilder<List<TailorWorkModel>>(
                    stream: getTailorsWorksStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Utilities.backgroundColor));
                      } else if (snapshot.hasError) {
                        if (Platform.isIOS) {
                          return IOSAlertDialogWidget(
                              title: 'Error',
                              content:
                                  'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                              actionButton1: 'Ok',
                              actionButton1OnTap: () {
                                Navigator.pop(context);
                              },
                              isDefaultAction1: true,
                              isDestructiveAction1: false);
                        } else {
                          return AndriodAleartDialogWidget(
                              title: 'Error',
                              content:
                                  'Unable to connect to the server. Please check your internet connection and try again.',
                              actionButton1: 'Ok',
                              actionButton1OnTap: () {
                                Navigator.pop(context);
                              });
                        }
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text(
                          'No work found',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ));
                      }
                      final tailorWorks = snapshot.data!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR SHOP',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 22.sp,
                              // letterSpacing: 1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                          Expanded(
                              child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 300,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10.w,
                                    mainAxisSpacing: 20.h,
                                  ),
                                  itemCount: tailorWorks.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return TailorSideWorkDetails(
                                            images: tailorWorks[index].images,
                                            title: tailorWorks[index].title,
                                            price: tailorWorks[index].price,
                                          );
                                        }));
                                      },
                                      child: TailorSideWorksWidget(
                                          imagePath: tailorWorks[index].images,
                                          title: tailorWorks[index].title,
                                          price: tailorWorks[index].price,
                                          productId:
                                              tailorWorks[index].productId),
                                    );
                                  }))
                        ],
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Utilities.primaryColor,
        onPressed: () {
          ref.read(tagsProvider.notifier).state = [];
          context.pushNamed('addNewWork');
        },
        child: const Icon(
          FluentSystemIcons.ic_fluent_add_filled,
          color: Utilities.backgroundColor,
        ),
      ),
    );
  }
}
