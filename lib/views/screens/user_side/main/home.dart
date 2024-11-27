// ignore_for_file: unused_import

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:stitches_africa/config/providers/bottom_bar_providers/user_side_bottom_bar_provider.dart';

import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_model_home_screen.dart';
import 'package:stitches_africa/views/components/search_field.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/home/tailor_feature_works_widget.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  final TextEditingController _searchTextController = TextEditingController();

  /// Fetches a stream of tailors based on the user's shopping preference
  Stream<List<TailorModelHomeScreen>> _getTailorsStream(
      String shoppingPreference) {
    return FirebaseFirestore.instance
        .collection('tailors')
        .where(
          'brand_category',
          arrayContains: shoppingPreference.toLowerCase(),
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TailorModelHomeScreen.fromDocument(doc, doc.data()))
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve user preferences from Hive
    final box = Hive.box('user_preferences');
    final user = box.get('user');
    final shoppingPreference = user['shoppingPreference'] ?? '';

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),

            /// Search Bar
            GestureDetector(
              onTap: () {
                // Navigate to the search screen
                ref.read(currentIndexProvider.notifier).state = 1;
              },
              child: AbsorbPointer(
                child: SearchTextField(
                  searchTextController: _searchTextController,
                  hintText: 'What bespoke piece are you after?',
                ),
              ),
            ),
            SizedBox(height: 25.h),

            /// Tailors StreamBuilder
            StreamBuilder<List<TailorModelHomeScreen>>(
              stream: _getTailorsStream(shoppingPreference),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Utilities.backgroundColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('An error occurred'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tailors found',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }

                // Display the list of tailors
                final tailors = snapshot.data!;
                return SizedBox(
                  height: 600.h,
                  child: ListView.builder(
                    itemCount: tailors.length,
                    itemBuilder: (context, index) {
                      final tailor = tailors[index];
                      return TailorFeatureWorksWidget(tailor: tailor);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
