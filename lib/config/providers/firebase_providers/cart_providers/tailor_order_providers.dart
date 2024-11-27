import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalOrderItemsProvider = StateProvider<int>((ref) => 0);
final orderStatusProvider = StateProvider<bool>((ref) => false);
