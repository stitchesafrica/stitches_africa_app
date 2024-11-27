// ignore_for_file: use_build_context_synchronously

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/models/firebase_models/recently_viewed_model.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/user_side/search/default_search_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/search/search_stream_or_futures_widget.dart/build_if_search_box_contains_text_stream.dart';
import 'package:stitches_africa/views/widgets/user_side/search/search_stream_or_futures_widget.dart/build_if_search_box_is_tapped_stream_widget.dart';
import 'package:toastification/toastification.dart';

class WomenTabBar extends ConsumerWidget {
  final List<String> list;
  WomenTabBar({super.key, required this.list});

  final Algolia algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification showToasitification = ShowToasitification();

  //algolia search query function
  Future<List<AlgoliaObjectSnapshot>> queryOperation(
      String input, BuildContext context) async {
    try {
      AlgoliaQuery query =
          algoliaApp.instance.index('tailor_works_index').query(input);
      query = query.facetFilter('category:women');

      AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
      List<AlgoliaObjectSnapshot> results = querySnapshot.hits;
      if (kDebugMode) {
        print('Searched Items: $results');
      }
      return results;
    } catch (e) {
      showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.error,
          title: 'Error searching for tailor work');
      if (kDebugMode) {
        print('Error searching: $e');
      }
      rethrow;
    }
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  Future<List<String>> getRecentSearchesForWomen() async {
    Box box = Hive.box('user_preferences');
    Map<String, dynamic> userPreferences =
        Map<String, dynamic>.from(await box.get('user') ?? {});

    return List<String>.from(userPreferences['recentSearchesWomen'] ?? []);
  }

  Stream<List<RecentlyViewedModel>> getRecentlyViewedItemsForWomenTab() {
    return FirebaseFirestore.instance
        .collection('users_viewed_items')
        .doc(getCurrentUserId())
        .collection('user_viewed_items')
        .where('category', isEqualTo: 'women')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RecentlyViewedModel.fromDocument(doc.data()))
            .toList());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? onChangedSearchTerm = ref.watch(onChangedSearchProvider);

    if (onChangedSearchTerm == null) {
      return _buildDefaultSearchScreenView();
    } else if (onChangedSearchTerm == '') {
      return _buildIfSearchBoxIsTapped();
    } else {
      return _buildIfSearchBoxContainsText(context, onChangedSearchTerm);
    }
  }

  //if the search box hasnt been tapped on i.e search ==null, build this widget
  Widget _buildDefaultSearchScreenView() {
    return DefaultSearchWidget(list: list);
  }

  //if the search box has been tapped on, build this widget
  Widget _buildIfSearchBoxIsTapped() {
    return BuildIfSearchBoxIsTappedStreamWidget(
        getRecentlyViewedItemsForWomenTab: getRecentlyViewedItemsForWomenTab(),
        getRecentSearchesForWomen: getRecentSearchesForWomen());
  }

  //if the search box contains text,build this widget
  Widget _buildIfSearchBoxContainsText(
      BuildContext context, String searchTerm) {
    final DocumentReference wishlistDocRef = FirebaseFirestore.instance
        .collection('usersWishlistItems')
        .doc(getCurrentUserId());
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference wishlistSubCollection =
        wishlistDocRef.collection('userWishlistItems');
    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
    return BuildIfSearchBoxContainsTextStream(
        wishlistSubCollection: wishlistSubCollection,
        cartCollection: cartSubCollection,
        querySnapshot: queryOperation(searchTerm, context));
  }
}
