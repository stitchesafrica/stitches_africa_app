import 'package:flutter_riverpod/flutter_riverpod.dart';

final totalCartItemsProvider = StateProvider<int>((ref) => 0);
final totalPriceProvider = StateProvider<double>((ref) => 0.0);
final onPanelOpenedProvider = StateProvider.autoDispose<bool>((ref) => false);
final mountedProvider = StateProvider<bool>((ref) => true);
