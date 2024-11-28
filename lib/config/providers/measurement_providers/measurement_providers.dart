import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final isAcceptedProvider = StateProvider((ref) => false);
final pageIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
final heightProvider = StateProvider<int>((ref) => 150);
final weightProvider = StateProvider<int>((ref) => 30);
final genderProvider = StateProvider<String>((ref) => 'female');
final frontPhotoProvider = StateProvider.autoDispose<File?>((ref) => null);
final sidePhotoProvider = StateProvider.autoDispose<File?>((ref) => null);
final updatedFieldsProvider =
    StateProvider.autoDispose<Map<String, dynamic>>((ref) => {});
final measurementErrorProvider =
    StateProvider.autoDispose<String?>((ref) => null);
