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

class RecentSearchWidget extends StatelessWidget {
  final List<String> recentSearches;
  RecentSearchWidget({super.key, required this.recentSearches});
  final Algolia algoliaApp = AlgoliaServiceApplication.algolia;
  final ShowToasitification showToasitification = ShowToasitification();

  //algolia search query function
  Future<int> queryHits(String input, BuildContext context) async {
    try {
      AlgoliaQuery query =
          algoliaApp.instance.index('tailor_works_index').query(input);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent searches',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        Expanded(
          child: ListView.builder(
              itemCount: recentSearches.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        });

                    await queryHits(recentSearches[index], context)
                        .then((hits) {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SearchedItemRoute(
                            searchTerm: recentSearches[index], hits: hits);
                      }));
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            FluentSystemIcons.ic_fluent_clock_regular,
                            color: Utilities.secondaryColor3,
                            size: 18,
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            recentSearches[index],
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      SizedBox(
                        width: 75.w,
                        child: const Divider(
                          thickness: 0.5,
                          color: Utilities.secondaryColor2,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      )
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
