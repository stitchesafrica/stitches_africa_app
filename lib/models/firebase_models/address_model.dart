class AddressModel {
  final String firstName;
  final String lastName;
  final String country;
  final String countryCode;
  final String streetAddress;
  String? flatNumber;
  final String state;
  final String city;
  final String postcode;
  final String dialCode;
  final String phoneNumber;

  AddressModel({
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.countryCode,
    required this.streetAddress,
    this.flatNumber,
    required this.state,
    required this.city,
    required this.postcode,
    required this.dialCode,
    required this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'country': country,
      'street_address': streetAddress,
      'flat_number': flatNumber,
      'state': state,
      'city': city,
      'post_code': postcode,
      'dial_code': dialCode,
      'phone_number': phoneNumber,
    };
  }

  factory AddressModel.fromDocument(Map<String, dynamic> doc) {
    return AddressModel(
      firstName: doc['first_name'],
      lastName: doc['last_name'],
      country: doc['country'],
      countryCode: doc['country_code'],
      streetAddress: doc['street_address'],
      flatNumber: doc['flat_number'] ?? '',
      state: doc['state'],
      city: doc['city'],
      postcode: doc['post_code'],
      dialCode: doc['dial_code'],
      phoneNumber: doc['phone_number'],
    );
  }
}
