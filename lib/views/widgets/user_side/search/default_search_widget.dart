// ignore_for_file: use_build_context_synchronously

import 'package:algolia/algolia.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/search/searched_item_route.dart';
import 'package:toastification/toastification.dart';

class DefaultSearchWidget extends StatelessWidget {
  final List<String> list;

  DefaultSearchWidget({super.key, required this.list});

  final Algolia _algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification _showToasitification = ShowToasitification();

  /// Performs an Algolia search query and returns the number of hits
  Future<int> _queryHits(String input, BuildContext context) async {
    try {
      AlgoliaQuery query =
          _algoliaApp.instance.index('tailor_works_index').query(input);
      AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
      List<AlgoliaObjectSnapshot> results = querySnapshot.hits;

      if (kDebugMode) {
        print('Searched Items: $results');
      }
      return results.length;
    } catch (e) {
      _showToasitification.showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: 'Error searching for tailor work',
      );
      if (kDebugMode) {
        print('Error searching: $e');
      }
      rethrow;
    }
  }

  /// Handles search tap and navigation to the results page
  Future<void> _handleSearchTap(BuildContext context, String searchTerm) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Utilities.backgroundColor),
        );
      },
    );

    try {
      final hits = await _queryHits(searchTerm, context);
      Navigator.pop(context); // Close loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SearchedItemRoute(searchTerm: searchTerm, hits: hits),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is dismissed on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final searchTerm = list[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Search Term
                Text(
                  searchTerm,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),

                /// Search Action
                GestureDetector(
                  onTap: () => _handleSearchTap(context, searchTerm),
                  child: const Icon(
                    FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
                    size: 18,
                  ),
                ),
              ],
            ),

            /// Divider
            SizedBox(height: 10.h),
            SizedBox(
              width: 75.w,
              child: const Divider(
                thickness: 0.5,
                color: Utilities.secondaryColor2,
              ),
            ),
            SizedBox(height: 10.h),
          ],
        );
      },
    );
  }
}
