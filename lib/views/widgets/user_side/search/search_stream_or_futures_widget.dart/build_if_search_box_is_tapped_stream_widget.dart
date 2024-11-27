import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/recently_viewed_model.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/user_side/search/recent_search_widget.dart';
import 'package:stitches_africa/views/widgets/user_side/search/recently_viewed_widget.dart';

class BuildIfSearchBoxIsTappedStreamWidget extends StatelessWidget {
  final Stream<List<RecentlyViewedModel>> getRecentlyViewedItemsForWomenTab;
  final Future<List<String>> getRecentSearchesForWomen;
  const BuildIfSearchBoxIsTappedStreamWidget(
      {super.key,
      required this.getRecentlyViewedItemsForWomenTab,
      required this.getRecentSearchesForWomen});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<RecentlyViewedModel>>(
            stream: getRecentlyViewedItemsForWomenTab,
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
                return const SizedBox.shrink();
              }
              final recentlyViewedItems = snapshot.data!;

              return RecentlyViewedWidget(
                  recentlyViewedItems: recentlyViewedItems);
            }),
        Expanded(
          child: FutureBuilder(
              future: getRecentSearchesForWomen,
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
                            'Unable to load recent searches.${snapshot.error}',
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
                            '${snapshot.error}',
                        actionButton1: 'Ok',
                        actionButton1OnTap: () {
                          Navigator.pop(context);
                        });
                  }
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }
                final recentSearchesWomen = snapshot.data!;

                return RecentSearchWidget(recentSearches: recentSearchesWomen);
              }),
        )
      ],
    );
  }
}
