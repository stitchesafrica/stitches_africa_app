import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/config/providers/tailor_list/tailor_list_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/user_side/search/search_stream_or_futures_widget.dart/tailor_list/build_if_tailor_search_box_contains_text_stream.dart';
import 'package:toastification/toastification.dart';

class TailorListWidget extends ConsumerStatefulWidget {
  final CollectionReference favoriteCollection;
  final String category;
  const TailorListWidget(
      {super.key, required this.favoriteCollection, required this.category});

  @override
  ConsumerState<TailorListWidget> createState() => _TailorListWidgetState();
}

class _TailorListWidgetState extends ConsumerState<TailorListWidget> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final Algolia algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification showToasitification = ShowToasitification();

  Map<String, List<Map<String, dynamic>>> groupedTailors = {};
  final Map<String, GlobalKey> _sectionKeys = {};
  Map<String, bool> favoriteStates = {};
  List<String> alphabetList = [];
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    fetchTailors();
  }

  Future<void> toggleFavoriteState(String tailorId, String brandName) async {
    bool isCurrentlyFavorite = favoriteStates[tailorId] ?? false;
    setState(() {
      favoriteStates[tailorId] = !isCurrentlyFavorite; // Toggle the state
    });

    // Add/remove from favorites in Firestore
    if (!isCurrentlyFavorite) {
      await firebaseFirestoreFunctions.addFavoriteTailor(
        widget.favoriteCollection,
        brandName,
        tailorId,
      );
    } else {
      await firebaseFirestoreFunctions.deleteFavoriteTailor(
        tailorId,
        widget.favoriteCollection,
      );
    }
  }

  Future<void> fetchTailors() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tailors')
        .where('brand_category', arrayContains: widget.category)
        .orderBy('brand_name')
        .get();

    Map<String, List<Map<String, dynamic>>> tempGroupedTailors = {};
    for (var doc in querySnapshot.docs) {
      String brandName = doc['brand_name'];
      String firstLetter = brandName[0].toUpperCase();

      // If this letter doesn't exist in the map, initialize it with an empty list
      if (!tempGroupedTailors.containsKey(firstLetter)) {
        tempGroupedTailors[firstLetter] = [];
      }

      // Add the document data along with the document ID
      Map<String, dynamic> tailorData = doc.data();
      tailorData['id'] = doc.id; // Add the document ID to the data

      tempGroupedTailors[firstLetter]!.add(tailorData);
      // Initialize favorite state for each tailor
      final isFavorite = await firebaseFirestoreFunctions.getFavoriteState(
        widget.favoriteCollection,
        doc.id,
      );
      favoriteStates[doc.id] = isFavorite;
    }

    setState(() {
      groupedTailors = tempGroupedTailors;
      alphabetList = groupedTailors.keys.toList()..sort();
    });
  }

  //algolia search query function
  Future<List<AlgoliaObjectSnapshot>> queryOperation(
      String input, BuildContext context) async {
    try {
      AlgoliaQuery query =
          algoliaApp.instance.index('tailors_index').query(input);
      // Set searchable attributes to target specific fields
      query = query.setAttributesToRetrieve(['brand_name']);

      // Filter where the array field `category` contains "women"
      query = query.facetFilter('brand_category:${widget.category}');

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

  void scrollToSection(String letter) {
    final key = _sectionKeys[letter];
    if (key != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Widget? getIconWidget(String tailorId, String brandName, List selectedTailors,
      bool isSelected, bool isFavorite) {
    if (selectedTailors.isEmpty) {
      return IconButton(
        icon: Icon(
          isFavorite
              ? FluentSystemIcons.ic_fluent_heart_filled
              : FluentSystemIcons.ic_fluent_heart_regular,
          size: 22,
          color: Utilities.primaryColor,
        ),
        onPressed: () => toggleFavoriteState(tailorId, brandName),
      );
    } else {
      if (isSelected) {
        return const Icon(FluentSystemIcons.ic_fluent_checkmark_filled,
            size: 22, color: Utilities.primaryColor);
      } else {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String? onChangedSearchTerm = ref.watch(onChangedSearchProvider);

    if (onChangedSearchTerm == null) {
      return _buildDefaultTailorList(ref);
    } else {
      return _buildIfSearchBoxContainsText(context, onChangedSearchTerm);
    }
  }

  Widget _buildDefaultTailorList(WidgetRef ref) {
    final List<Map<String, dynamic>> selectedTailors =
        ref.watch(selectedTailorsProvider);
    void toggleSelection(Map<String, dynamic> tailor) {
      if (selectedTailors.contains(tailor)) {
        ref.read(selectedTailorsProvider.notifier).update((state) {
          List<Map<String, dynamic>> updatedTags =
              List.from(state); // Copy current list
          updatedTags.remove(tailor); // Add new tag
          return updatedTags;
        });
      } else {
        ref.read(selectedTailorsProvider.notifier).update((state) {
          List<Map<String, dynamic>> updatedTags =
              List.from(state); // Copy current list
          updatedTags.add(tailor); // Add new tag
          return updatedTags;
        });
      }
    }

    return Expanded(
      // Use Expanded to make the Row widget bounded by the remaining height.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: alphabetList.length,
              itemBuilder: (context, index) {
                String letter = alphabetList[index];
                List<Map<String, dynamic>> tailors =
                    groupedTailors[letter] ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Letter Header
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        letter,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    // Tailor List
                    ...tailors.map((tailor) {
                      bool isSelected = selectedTailors.contains(tailor);
                      String tailorId = tailor['id'];
                      bool isFavorite = favoriteStates[tailorId] ?? false;
                      return GestureDetector(
                        onTap: () => toggleSelection(tailor),
                        child: ListTile(
                            title: Text(
                              tailor['brand_name'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                            trailing: getIconWidget(
                                tailor['id'],
                                tailor['brand_name'],
                                selectedTailors,
                                isSelected,
                                isFavorite)),
                      );
                    }),
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
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: 10.w,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: alphabetList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    scrollToSection(alphabetList[index]);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      alphabetList[index],
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
    return BuildIfTailorSearchBoxContainsTextStream(
        wishlistSubCollection: wishlistSubCollection,
        cartCollection: cartSubCollection,
        querySnapshot: queryOperation(searchTerm, context));
  }
}
