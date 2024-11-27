import 'package:flutter_riverpod/flutter_riverpod.dart';

final fullNameProvider = StateProvider<String>((ref) => '');
final dayProvider = StateProvider<String>((ref) => '');
final monthProvider = StateProvider<String>((ref) => '');
final yearProvider = StateProvider<String>((ref) => '');
final faceImageProvider = StateProvider<String>((ref) => '');
final identityProvider = StateProvider<String>((ref) => '');
final streetAddressProvider = StateProvider<String>((ref) => '');
final cityProvider = StateProvider<String>((ref) => '');
final stateProvider = StateProvider<String>((ref) => '');
final postalCodeProvider = StateProvider<String>((ref) => '');
final countryProvider = StateProvider<String>((ref) => '');
final addressImageProvider = StateProvider<String>((ref) => '');
final tailorBrandNameProvider = StateProvider<String>((ref) => '');
final tailorTaglineProvider = StateProvider<String>((ref) => '');
final tailorLogoProvider = StateProvider<String>((ref) => '');
final tailorEmailAddressProvider = StateProvider<String>((ref) => '');
final tailorDialCodeProvider = StateProvider<String>((ref) => '');
final tailorPhoneNumberProvider = StateProvider<String>((ref) => '');
final mediaPathsProvider = StateProvider<List<String>>((ref) => []);

final isToUpdateInfoProvider = StateProvider<bool>((ref) => false); //
