import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_model_home_screen.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';

class FavoriteTailorWidget extends StatefulWidget {
  final CollectionReference favoriteCollection;
  final String tailorId;
  final String tailorName;
  const FavoriteTailorWidget(
      {super.key,
      required this.tailorName,
      required this.favoriteCollection,
      required this.tailorId});

  @override
  State<FavoriteTailorWidget> createState() => _FavoriteTailorWidgetState();
}

class _FavoriteTailorWidgetState extends State<FavoriteTailorWidget> {
  FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  bool isFavorite = false;
  Future<void> setFavoriteState() async {
    print(widget.tailorId);
    final temporaryBookmarkedState = await firebaseFirestoreFunctions
        .getFavoriteState(widget.favoriteCollection, widget.tailorId);

    if (mounted) {
      setState(() {
        isFavorite = temporaryBookmarkedState;
      });
    }
  }

  Future<void> toggleFavoriteState(String tailorId, String brandName) async {
    // Add/remove from favorites in Firestore
    if (!isFavorite) {
      await firebaseFirestoreFunctions
          .addFavoriteTailor(
            widget.favoriteCollection,
            brandName,
            tailorId,
          )
          .then((value) => setFavoriteState());
    } else {
      await firebaseFirestoreFunctions
          .deleteFavoriteTailor(
            tailorId,
            widget.favoriteCollection,
          )
          .then((value) => setFavoriteState());
    }
  }

  Stream<List<TailorModelHomeScreen>> getTailorsStream() {
    return FirebaseFirestore.instance
        .collection('tailors')
        .where('brand_name', isEqualTo: widget.tailorName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TailorModelHomeScreen.fromDocument(doc, doc.data()))
            .toList());
  }

  @override
  void initState() {
    super.initState();
    setFavoriteState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 100.h,
          child: Container(
            height: 85.h,
            padding: EdgeInsets.symmetric(
              horizontal: 15.w,
              vertical: 5.h,
            ),
            decoration: BoxDecoration(
                border: Border.all(
              color: Utilities.primaryColor,
            )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isFavorite
                            ? FluentSystemIcons.ic_fluent_heart_filled
                            : FluentSystemIcons.ic_fluent_heart_regular,
                        size: 22,
                        color: Utilities.primaryColor,
                      ),
                      onPressed: () => toggleFavoriteState(
                          widget.tailorId, widget.tailorName),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Text(
                      widget.tailorName,
                    ),
                  ],
                ),
                StreamBuilder(
                    stream: getTailorsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final imageUrl = snapshot.data!.first.works.first;
                        return SizedBox(
                          width: 80.w,
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    })
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h,),
      ],
    );
  }
}
