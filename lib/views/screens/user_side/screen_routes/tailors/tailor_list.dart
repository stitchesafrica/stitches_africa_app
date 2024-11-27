import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/search_providers/search_providers.dart';
import 'package:stitches_africa/config/providers/tailor_list/tailor_list_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/algolia_service/algolia_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/search_field.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/tailors_list_wears_route.dart';
import 'package:stitches_africa/views/widgets/user_side/tailor_list/tailor_list_widget.dart';
import 'package:toastification/toastification.dart';

class TailorList extends ConsumerStatefulWidget {
  final String category;
  const TailorList({super.key, required this.category});

  @override
  ConsumerState<TailorList> createState() => _TailorListState();
}

class _TailorListState extends ConsumerState<TailorList> {
  final TextEditingController searchTextController = TextEditingController();
  final Algolia algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification showToasitification = ShowToasitification();

  //algolia search query function
  Future<int> queryHits(String input, BuildContext context) async {
    try {
      AlgoliaQuery query =
          algoliaApp.instance.index('tailors_index').query(input);

      AlgoliaQuerySnapshot querySnapshot = await query.getObjects();
      List<AlgoliaObjectSnapshot> results = querySnapshot.hits;
      if (kDebugMode) {
        print('Searched Items: $results');
      }
      return results.length;
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

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  @override
  Widget build(BuildContext context) {
    final searchTabBarIndex = ref.watch(searchTabBarIndexProvider);
    final CollectionReference favoriteCollection = FirebaseFirestore.instance
        .collection('users_favorite_tailors')
        .doc(getCurrentUserId())
        .collection('user_favorite_tailors');
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');
    final List<Map<String, dynamic>> selectedTailors =
        ref.watch(selectedTailorsProvider);
    void removeSelection(Map<String, dynamic> tailor) {
      ref.read(selectedTailorsProvider.notifier).update((state) {
        List<Map<String, dynamic>> updatedTags =
            List.from(state); // Copy current list
        updatedTags.remove(tailor); // Add new tag
        return updatedTags;
      });
    }

    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
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
        title: Text(
          'Tailors',
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Utilities.backgroundColor));
                  });
              await firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);
              Navigator.pop(context);
              context.pushNamed('shoppingScreen');
            },
            child: SvgPicture.asset(
              'assets/icons/bag.svg',
              height: 22.h,
            ),
          ),
          SizedBox(
            width: 8.w,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            SizedBox(
              height: 10.h,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     SizedBox(
            //       width: 100.w,
            //       child: ButtonIcon(
            //           text: 'Refine',
            //           sizedBoxWidth: 5,
            //           paddingWidth: 10.w,
            //           paddingTop: 8.h,
            //           iconPath: 'assets/icons/sort-by-line.svg',
            //           border: true),
            //     ),
            //   ],
            // ),
            SizedBox(
              height: 10.h,
            ),
            SearchTextField(
              searchTextController: searchTextController,
              hintText: 'Explore Tailors',
              onChanged: (value) {
                ref.read(onChangedSearchProvider.notifier).state = value;
              },
            ),
            SizedBox(
              height: 20.h,
            ),
            if (selectedTailors.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedTailors
                      .map((tailor) => Padding(
                            padding: EdgeInsets.only(
                                left: 4.w, right: 4.w, bottom: 10.h),
                            child: Chip(
                              backgroundColor: Utilities.backgroundColor,
                              side: const BorderSide(
                                color: Utilities.primaryColor,
                              ),
                              label: Text(
                                tailor['brand_name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400),
                              ),
                              deleteIcon: const Icon(
                                FluentSystemIcons.ic_fluent_dismiss_regular,
                                size: 14,
                              ),
                              onDeleted: () => removeSelection(tailor),
                            ),
                          ))
                      .toList(),
                ),
              ),
            TailorListWidget(
              favoriteCollection: favoriteCollection,
              category: widget.category,
            )
          ],
        ),
      ),
      bottomNavigationBar: selectedTailors.isNotEmpty
          ? BottomAppBar(
              height: 40.h,
              elevation: 0,
              color: Utilities.backgroundColor,
              padding: EdgeInsets.zero,
              child: Button(
                border: false,
                text: 'Shop ${selectedTailors.length} tailors',
                onTap: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return TailorsListWearsRoute(
                        favoriteCollection: favoriteCollection,
                        selectedTailors: selectedTailors);
                  }));
                },
              ),
            )
          : null,
    );
  }
}
