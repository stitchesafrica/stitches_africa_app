import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stitches_africa/models/firebase_models/address_model.dart';

final selectedAddressProvider = StateProvider<AddressModel?>((ref) => null);
