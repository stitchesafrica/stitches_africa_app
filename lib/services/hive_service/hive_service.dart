import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  Future<void> saveUserData({
    String? firstName,
    String? lastName,
    String? shoppingPreference,
    String? womenSearches,
    String? menSearches,
    String? kidsSearches,
  }) async {
    Box box = Hive.box('user_preferences');
    await box.put('user', {
      'firstName': firstName,
      'lastName': lastName,
      'shoppingPreference': shoppingPreference,
      'recentSearchesWomen': womenSearches ?? [], // Initialize as empty if null
      'recentSearchesMen': menSearches ?? [],
      'recentSearchesKids': kidsSearches ?? [],
    });
  }

  Future<void> saveUserSearches({
    String? womenSearches,
    String? menSearches,
    String? kidsSearches,
  }) async {
    Box box = Hive.box('user_preferences');
    Map<String, dynamic> userPreferences =
        Map<String, dynamic>.from(await box.get('user'));

    if (womenSearches != null) {
      List<String> recentSearchesWomen =
          List<String>.from(userPreferences['recentSearchesWomen'] ?? []);
      // Check if the search term already exists
      if (!recentSearchesWomen.contains(womenSearches)) {
        recentSearchesWomen.add(womenSearches);
        userPreferences['recentSearchesWomen'] = recentSearchesWomen;
      }
    } else if (menSearches != null) {
      List<String> recentSearchesMen =
          List<String>.from(userPreferences['recentSearchesMen'] ?? []);
      // Check if the search term already exists
      if (!recentSearchesMen.contains(menSearches)) {
        recentSearchesMen.add(menSearches);
        userPreferences['recentSearchesMen'] = recentSearchesMen;
      }
    } else if (kidsSearches != null) {
      List<String> recentSearchesKids =
          List<String>.from(userPreferences['recentSearchesKids'] ?? []);

      if (!recentSearchesKids.contains(kidsSearches)) {
        recentSearchesKids.add(kidsSearches);
        userPreferences['recentSearchesKids'] = recentSearchesKids;
      }
    }

    await box.put('user', userPreferences);
  }

  // Future<void> clearUserSession() async {
  //   var box = Hive.box('user_preferences');
  //   box.clear();
  // }
}
