import 'package:flutter_riverpod/flutter_riverpod.dart';

final onChangedSearchProvider =
    StateProvider.autoDispose<String?>((ref) => null);
final onSubmittedSearchProvider =
    StateProvider<String?>((ref) => null);
final searchTabBarIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
