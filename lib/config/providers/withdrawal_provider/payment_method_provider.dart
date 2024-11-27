import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentMethodProvider = StateProvider((ref) => 'Online Bank');
final amountProvider = StateProvider<double>((ref) => 0.0);
