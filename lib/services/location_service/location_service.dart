import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';

class LocationService {
  void _showLocationPermissionDialog(BuildContext context) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Location Access Required',
            content:
                'To use this feature, you need to enable location access in the app settings.',
            button1Text: 'Cancel',
            button2Text: 'Open Settings',
            onButton1Pressed: () => Navigator.pop(context),
            onButton2Pressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          );
        },
      );
    } else {
      // Material AlertDialog for Android
      showDialog(
        context: context,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Location Access Required',
            content:
                'To use this feature, you need to enable location access in the app settings.',
            button1Text: 'Cancel',
            button2Text: 'Open Settings',
            button1BorderEnabled: true,
            button2BorderEnabled: false,
            onButton1Pressed: () => Navigator.pop(context),
            onButton2Pressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
          );
        },
      );
    }
  }

  Future<Position> getUserLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (Platform.isIOS) {
        // Cupertino Dialog for iOS
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text(
                'Location service is not enabled',
                style: TextStyle(),
              ),
              content: Text(
                'Turn on location service in your settings: Settings > Location > Turn ON.',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Material AlertDialog for Android
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Utilities.backgroundColor,
              title: const Text(
                'Location service is not enabled',
                style: TextStyle(),
              ),
              content: Text(
                'Turn on location service in your settings: Settings > Location > Turn ON.',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Ok',
                    style: TextStyle(
                      color: Utilities.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationPermissionDialog(context);
    }

    final Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return location;
  }

  Future<String> getCountry(BuildContext context) async {
    // Get the current location of the user
    Position position = await getUserLocation(context);

    // Reverse geocode to get the address information
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    // Get the country from the placemark
    String country = placemarks.first.country ?? 'Unknown';

    return country;
  }

  Future<List<Map<String, dynamic>>> loadCountryData() async {
    // Load the JSON file from assets
    final String jsonString =
        await rootBundle.loadString('assets/json/countries.json');

    // Decode the JSON string
    final List<dynamic> jsonData = json.decode(jsonString);

    // Convert the dynamic list to a list of maps
    return jsonData.map((country) => country as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>?> findCountryData(String countryName) async {
    final countries = await loadCountryData();
    for (var country in countries) {
      if (country['Country'] == countryName) {
        return country;
      }
    }
    return null; // Return null if country is not found
  }
}
