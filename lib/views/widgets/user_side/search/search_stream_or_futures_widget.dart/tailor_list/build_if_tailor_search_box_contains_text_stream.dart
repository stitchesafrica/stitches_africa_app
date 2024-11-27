import 'dart:io';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/tailor_list/tailor_list_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';

class BuildIfTailorSearchBoxContainsTextStream extends ConsumerWidget {
  final CollectionReference wishlistSubCollection;
  final CollectionReference cartCollection;
  final Future<List<AlgoliaObjectSnapshot>> querySnapshot;

  BuildIfTailorSearchBoxContainsTextStream({
    super.key,
    required this.wishlistSubCollection,
    required this.cartCollection,
    required this.querySnapshot,
  });

  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, List<AlgoliaObjectSnapshot>> groupedTailors = {};
  final List<String> alphabetList = [];

  Future<void> groupTailorsByLetter(
      List<AlgoliaObjectSnapshot> searchResults) async {
    groupedTailors.clear();
    for (var snapshot in searchResults) {
      final data = snapshot.data;
      final brandName = data['brand_name'] as String;
      final firstLetter = brandName[0].toUpperCase();

      if (!groupedTailors.containsKey(firstLetter)) {
        groupedTailors[firstLetter] = [];
      }
      groupedTailors[firstLetter]!.add(snapshot);
    }

    alphabetList
      ..clear()
      ..addAll(groupedTailors.keys.toList()..sort());

    // Assign GlobalKeys for each section
    for (var letter in alphabetList) {
      _sectionKeys[letter] = GlobalKey();
    }
  }

  void scrollToSection(String letter) {
    if (_sectionKeys.containsKey(letter)) {
      Scrollable.ensureVisible(
        _sectionKeys[letter]!.currentContext!,
        duration: const Duration(milliseconds: 300),
        alignment: 0.1,
      );
    }
  }

  Widget? getIconWidget(List selectedTailors, bool isSelected) {
    if (selectedTailors.isEmpty) {
      return const Icon(
        Icons.favorite_border,
        size: 22,
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
  Widget build(BuildContext context, WidgetRef ref) {
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

    return FutureBuilder<List<AlgoliaObjectSnapshot>>(
      future: querySnapshot,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Utilities.backgroundColor),
          );
        } else if (snapshot.hasError) {
          return Platform.isIOS
              ? IOSAlertDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () => Navigator.pop(context),
                  isDefaultAction1: true,
                  isDestructiveAction1: false,
                )
              : AndriodAleartDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () => Navigator.pop(context),
                );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No tailor found'),
          );
        }

        List<AlgoliaObjectSnapshot> currentSearchResult = snapshot.data!;
        groupTailorsByLetter(currentSearchResult);

        return Expanded(
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
                    List<AlgoliaObjectSnapshot> tailors =
                        groupedTailors[letter] ?? [];

                    return Column(
                      key: _sectionKeys[letter],
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Letter Header
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            letter,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Tailor List
                        ...tailors.map((tailor) {
                          final data = tailor.data;
                          bool isSelected = selectedTailors.contains(tailor);
                          return GestureDetector(
                            onTap: () => toggleSelection(data),
                            child: ListTile(
                                title: Text(
                                  data['brand_name'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400),
                                ),
                                trailing:
                                    getIconWidget(selectedTailors, isSelected)),
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
              // Side Alphabet Index
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
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
