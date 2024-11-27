// ignore_for_file: use_build_context_synchronously

import 'package:algolia/algolia.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/services/hive_service/hive_service.dart';
import 'package:stitches_africa/views/components/search_field.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/search/searched_item_route.dart';
import 'package:stitches_africa/views/widgets/user_side/search/tab_bar/search_tab_bar.dart';
import 'package:toastification/toastification.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final HiveService _hiveService = HiveService();
  final TextEditingController _searchTextController = TextEditingController();
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

  /// Handles search submission and saves the search history
  Future<void> _onSearchSubmitted(
      String value, int searchTabBarIndex, BuildContext context) async {
    switch (searchTabBarIndex) {
      case 0:
        await _hiveService.saveUserSearches(womenSearches: value);
        break;
      case 1:
        await _hiveService.saveUserSearches(menSearches: value);
        break;
      case 2:
        await _hiveService.saveUserSearches(kidsSearches: value);
        break;
    }

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
      final hits = await _queryHits(value, context);
      Navigator.pop(context); // Close loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SearchedItemRoute(searchTerm: value, hits: hits),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Ensure dialog is dismissed on error
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchTabBarIndex = ref.watch(searchTabBarIndexProvider);
    final focusNode = FocusNode()..requestFocus();

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: DefaultTabController(
        length: 3,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              /// Title
              Text(
                'SEARCH',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.h),

              /// Search Field
              SearchTextField(
                searchTextController: _searchTextController,
                focusNode: focusNode,
                hintText: 'Explore exclusive tailored pieces',
                onChanged: (value) {
                  ref.read(onChangedSearchProvider.notifier).state = value;
                },
                onSubmitted: (value) async {
                  ref.read(onSubmittedSearchProvider.notifier).state = value;
                  await _onSearchSubmitted(value, searchTabBarIndex, context);
                },
              ),
              SizedBox(height: 20.h),

              /// Tab Bar with Search Content
              const Expanded(child: SearchTabBar()),
            ],
          ),
        ),
      ),
    );
  }
}
