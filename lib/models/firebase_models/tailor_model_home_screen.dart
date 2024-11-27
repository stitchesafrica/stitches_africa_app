import 'package:cloud_firestore/cloud_firestore.dart';

class TailorModelHomeScreen {
  final String docID;
  final String tailorName;
  final String tailorMotto;
  final String tailorLogo;
  final List<String> works;
  TailorModelHomeScreen({
    required this.docID,
    required this.tailorName,
    required this.tailorMotto,
    required this.tailorLogo,
    required this.works,
  });

  factory TailorModelHomeScreen.fromDocument(
      DocumentSnapshot doc, Map<String, dynamic> data) {
    return TailorModelHomeScreen(
      docID: doc.id,
      tailorName: doc['brand_name'] ?? '',
      tailorMotto: doc['tagline'] ?? '',
      tailorLogo: doc['logo'] ?? '',
      works: List<String>.from(doc['featured_works'] ?? []),
    );
  }
}
