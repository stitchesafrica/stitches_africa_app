import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTailorsProvider =
    StateProvider.autoDispose<List<Map<String, dynamic>>>((ref) => []);
