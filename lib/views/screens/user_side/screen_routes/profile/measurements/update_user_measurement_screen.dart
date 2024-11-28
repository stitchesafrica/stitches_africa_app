// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/api/measurement/manual_calculation_model.dart';
import 'package:stitches_africa/services/api_service/measurements/measurement_api_service.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_dialog.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';

class UpdateUserMeasurementScreen extends ConsumerStatefulWidget {
  const UpdateUserMeasurementScreen({super.key});

  @override
  ConsumerState<UpdateUserMeasurementScreen> createState() =>
      _UpdateUserMeasurementScreenState();
}

class _UpdateUserMeasurementScreenState
    extends ConsumerState<UpdateUserMeasurementScreen> {
  final PageController _pageController = PageController();

  final MeasurementApiService _measurementApiService = MeasurementApiService();

  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  final ImagePicker _picker = ImagePicker();

  File? frontImageFile;
  File? sideImageFile;
  Timer? _timer;
  String? measurementError;

  bool canRetryScan = false;

  @override
  void dispose() {
    // Cancel the timer if it exists
    _timer?.cancel();
    super.dispose();
  }

  final List<String> images = [
    'assets/images/step1.png',
    'assets/images/step1_2.png',
    'assets/images/step2.png',
    'assets/images/step3.png',
    'assets/images/step4.png',
    'assets/images/step5.png',
    'assets/images/step6.png',
    'assets/images/step7.png',
    'assets/images/step7_2.png',
  ];

  /// Picks an image from the specified source (camera or gallery)
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxHeight: 1920,
        maxWidth: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (pickedFile != null) {
        if (kDebugMode) {
          print('pickedFile:$pickedFile');
        }
        return File(pickedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error picking image: $e");
      }
    }
    return null;
  }

  Future<void> selectImage({required bool isFrontPhoto}) async {
    File? selectedImageFile;

    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      await showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Select Image Source',
            content:
                'Choose how you\'d like to upload your image: take a photo with your camera or select one from your gallery.',
            button1Text: 'Camera',
            button2Text: 'Gallery',
            onButton1Pressed: () async {
              selectedImageFile = await pickImage(source: ImageSource.camera);
              context.pop();
            },
            onButton2Pressed: () async {
              selectedImageFile = await pickImage(source: ImageSource.gallery);
              context.pop();
            },
          );
        },
      );
    } else {
      // Material AlertDialog for Android
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Select Image Source',
            content:
                'Choose how you\'d like to upload your image: take a photo with your camera or select one from your gallery.',
            button1Text: 'Camera',
            button2Text: 'Gallery',
            button1BorderEnabled: true,
            button2BorderEnabled: true,
            onButton1Pressed: () async {
              selectedImageFile = await pickImage(source: ImageSource.camera);
              context.pop();
            },
            onButton2Pressed: () async {
              selectedImageFile = await pickImage(source: ImageSource.gallery);
              context.pop();
            },
          );
        },
      );
    }

    // Update the provider state after image is picked
    if (selectedImageFile != null) {
      if (isFrontPhoto) {
        ref.read(frontPhotoProvider.notifier).state = selectedImageFile;
        if (kDebugMode) {
          print('Front Image path: ${selectedImageFile!.path}');
        }
      } else {
        ref.read(sidePhotoProvider.notifier).state = selectedImageFile;
        if (kDebugMode) {
          print('Side Image path: ${selectedImageFile!.path}');
        }
      }
    } else {
      if (kDebugMode) {
        print('No image selected.');
      }
    }
  }

  void _showInstructions(File? frontPhoto, File? sidePhoto) {
    if (Platform.isIOS) {
      // Cupertino Dialog for iOS
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomTwoButtonCupertinoDialog(
            title: 'Measurement Calculation in Progress',
            content:
                'Please note that the process to calculate your measurements may take some time. Do not quit the app and kindly remain patient while we process your data.',
            button1Text: 'Cancel',
            button2Text: 'Proceed',
            onButton1Pressed: () => context.pop(),
            onButton2Pressed: () async {
              context.pop();
              await calculateMeasurement(frontPhoto, sidePhoto);
            },
          );
        },
      );
    } else {
      // Material AlertDialog for Android
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return CustomTwoButtonAlertDialog(
            title: 'Measurement Calculation in Progress',
            content:
                'Please note that the process to calculate your measurements may take some time. Do not quit the app and kindly remain patient while we process your data.',
            button1Text: 'Cancel',
            button2Text: 'Proceed',
            button1BorderEnabled: true,
            button2BorderEnabled: true,
            onButton1Pressed: () => context.pop(),
            onButton2Pressed: () async {
              context.pop();
              await calculateMeasurement(frontPhoto, sidePhoto);
            },
          );
        },
      );
    }
  }

  Future<void> calculateMeasurement(File? frontPhoto, File? sidePhoto) async {
    print(measurementError);
    if ((frontPhoto == null) || (sidePhoto == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Front and side photos are required. Refer to the guide for help.',
          ),
        ),
      );
      return;
    } else if (measurementError != null) {
      await _retryCalculation(frontPhoto, sidePhoto);
    } else {
      try {
        _showLoadingDialog();
        final data = await _firebaseFirestoreFunctions
            .getUserMeasurementData(_getCurrentUserId());
        if (data != null) {
          // update person
          final updatedPersonModel = await _measurementApiService.updatePerson(
            id: data['id'],
            frontImage: frontPhoto,
            sideImage: sidePhoto,
          );
          if (kDebugMode) {
            print(updatedPersonModel.taskSetUrl);
          }
          //store task url in db
          await _firebaseFirestoreFunctions
              .syncUserMeasurementDataWithAPI(_getCurrentUserId(), {
            'task_set_url': updatedPersonModel.taskSetUrl,
          });

          //get task specific set
          final String taskSetId =
              extractTaskSetId(updatedPersonModel.taskSetUrl);
          if (kDebugMode) {
            print(taskSetId);
          }

          // Periodically check the task set status
          await periodicallyCheckTaskSet(taskSetId);
        }
      } catch (e) {
        if (mounted) {
          context.pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An error occurred while calculating your measurements. Please try again.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _retryCalculation(File? frontPhoto, File? sidePhoto) async {
    if ((frontPhoto == null) || (sidePhoto == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Front and side photos are required. Refer to the guide for help.',
          ),
        ),
      );
      return;
    }
    try {
      if (measurementError!.contains('front photo in the side') ||
          measurementError!.contains('side photo in the front') ||
          measurementError!.contains('detect the human body') ||
          measurementError!.contains('the pose is wrong') ||
          measurementError!.contains('the body is not full')) {
        _showLoadingDialog();
        final data = await _firebaseFirestoreFunctions
            .getUserMeasurementData(_getCurrentUserId());

        if (data != null) {
          // Partial Update a Specific Person
          await _measurementApiService.partialUpdatePerson(
            id: data['id'],
            frontImage: frontPhoto,
            sideImage: sidePhoto,
          );

          final manualCalculationModel = await _measurementApiService
              .startManualCalculation(id: data['id']);
          if (kDebugMode) {
            print(manualCalculationModel.taskSetUrl);
          }
          //store task url in db
          await _firebaseFirestoreFunctions
              .syncUserMeasurementDataWithAPI(_getCurrentUserId(), {
            'task_set_url': manualCalculationModel.taskSetUrl,
          });
          //get task specific set
          final String taskSetId =
              extractTaskSetId(manualCalculationModel.taskSetUrl);
          if (kDebugMode) {
            print(taskSetId);
          }

          // Periodically check the task set status
          await periodicallyCheckTaskSet(taskSetId);
        }
      }
    } catch (e) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'An error occurred while retrying the calculation. Please try again.',
        ),
      ));
    }
  }

  Future<void> periodicallyCheckTaskSet(String taskSetId) async {
    try {
      // Call the getTaskSet function
      final taskSetModel = await _measurementApiService.getTaskSet(taskSetId);

      // Extract fields
      final taskSet = taskSetModel.taskSet;
      final volumeParams = taskSetModel.volumeParams;
      final sideParams = taskSetModel.sideParams;
      final frontParams = taskSetModel.frontParams;

      // Print values for debugging
      if (kDebugMode) {
        print('Task Set: $taskSet');
        print('Volume Params: $volumeParams');
        print('Side Params: $sideParams');
        print('Front Params: $frontParams');
      }

      if (taskSet != null) {
        // Check if task is ready
        final isReady = taskSet['is_ready'] as bool? ?? false;
        final isSuccessful = taskSet['is_successful'];

        if (isReady && isSuccessful == true) {
          // Ensure all required data is available
          if (volumeParams != null &&
              sideParams != null &&
              frontParams != null) {
            // Update the measurement data in Firestore
            await _firebaseFirestoreFunctions.syncUserMeasurementDataWithAPI(
              _getCurrentUserId(),
              {
                'task_set': taskSet,
                'volume_params': volumeParams,
                'side_params': sideParams,
                'front_params': frontParams,
              },
            );

            if (kDebugMode) {
              print('User Measurement updated successfully');
            }

            // Ensure the widget is still mounted before dismissing the dialog
            if (mounted) {
              context.pop();
              //go to the measurement page
              context
                  .goNamed('measurementsScreen'); // Dismiss the loading dialog
            }
          } else {
            // If data is incomplete, poll again
            if (kDebugMode) {
              print('Data incomplete. Polling again...');
            }
            await Future.delayed(const Duration(seconds: 5));
            if (mounted) {
              await periodicallyCheckTaskSet(taskSetId); // Recursive call
            }
          }
        } else if (isReady && isSuccessful == false) {
          // Handle unsuccessful measurement calculation
          if (mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Measurement failed. Retake photos and refer to the guide for help.',
                ),
              ),
            );
          }
        } else if (isReady && isSuccessful == false) {
          if (mounted) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Measurement failed. Retake photos and refer to the guide for help.',
                ),
              ),
            );
          }
        } else {
          // is_ready == false, keep polling
          await Future.delayed(const Duration(seconds: 5));
          if (mounted) {
            await periodicallyCheckTaskSet(taskSetId); // Recursive call
          }
        }
      } else {
        await Future.delayed(const Duration(seconds: 5));
        if (mounted) {
          await periodicallyCheckTaskSet(taskSetId); // Recursive call
        }
      }
    } catch (e) {
      setState(() {
        canRetryScan = true;
      });
      measurementError = e.toString().toLowerCase();
      // Handle errors and ensure the widget is still mounted before dismissing dialog
      if (mounted) {
        context.pop(); // Dismiss the loading dialog
      }

      if (kDebugMode) {
        print('An error occurred: ${e.toString()}');
      }

      // Optionally show an error message to the user
      if (measurementError!.contains('front photo in the side')) {
        _showErrorDialog('Front photo in the side');
      } else if (measurementError!.contains('side photo in the front')) {
        _showErrorDialog('Side photo in the front');
      } else if (measurementError!.contains('detect the human body')) {
        _showErrorDialog('Can not detect human body');
      } else if (measurementError!.contains('the pose is wrong')) {
        _showErrorDialog('The pose is wrong');
      } else if (measurementError!.contains('the body is not full')) {
        _showErrorDialog('The body is not full');
      } else {
        _showErrorDialog('');
      }
    }
  }

  String extractTaskSetId(String url) {
    final RegExp regex = RegExp(r'queue\/([a-f0-9\-]+)/');
    final Match? match = regex.firstMatch(url);
    if (match != null) {
      return match.group(1)!; // Return the extracted task_set_id
    } else {
      throw Exception('Invalid URL or task_set_id not found.');
    }
  }

  String _getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  /// Displays a loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Utilities.backgroundColor),
      ),
    );
  }

  void _showErrorDialog(String subText) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error occurred while processing your request. $subText. Please try again.',
          ),
        ),
      );
    }
  }

  /// Builds a label for input fields
  Widget _buildLabel(String label, {double? fontSize}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: fontSize ?? 14.sp,
        color: Utilities.primaryColor,
      ),
    );
  }

  Widget _buildViewImage(File? frontPhoto, File? sidePhoto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (frontPhoto != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenFileImage(
                          filePath: frontPhoto,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: frontPhoto,
                    child: SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: Image.file(frontPhoto)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'view uploaded image',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Utilities.secondaryColor3,
                ),
              ),
            ],
          )
        else
          const SizedBox.shrink(),
        SizedBox(
          width: 10.w,
        ),
        if (sidePhoto != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenFileImage(
                          filePath: sidePhoto,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: sidePhoto,
                    child: SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: Image.file(sidePhoto)),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'view uploaded image',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Utilities.secondaryColor3,
                ),
              ),
            ],
          )
        else
          const SizedBox.shrink()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final frontPhoto = ref.watch(frontPhotoProvider);
    final sidePhoto = ref.watch(sidePhotoProvider);
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 75.h,
            ),
            Row(
              children: [
                Expanded(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: images.length,
                    effect: ExpandingDotsEffect(
                      expansionFactor: 7.w,
                      dotWidth: 11.w,
                      dotHeight: 5.h,
                      radius: 0.r,
                      activeDotColor: Utilities.primaryColor,
                      dotColor: Utilities.secondaryColor3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Transform.flip(
                    flipX: true,
                    child: const Icon(
                      FluentSystemIcons.ic_fluent_dismiss_filled,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 200.h,
            ),
            _buildLabel('HOW TO SCAN GUIDE'),
            SizedBox(
              height: 225.h,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(pageIndexProvider.notifier).state = index;
                },
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageUrl: images[index],
                            imageProvider: AssetImage(
                              images[index],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: images[index],
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  FluentSystemIcons.ic_fluent_info_regular,
                  size: 12,
                  color: Utilities.secondaryColor,
                ),
                SizedBox(
                  width: 4.w,
                ),
                Text(
                  "Tap on the image to view it in full screen.",
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: Utilities.secondaryColor,
                      fontWeight: FontWeight.w400),
                )
              ],
            ),
            SizedBox(
              height: 50.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Button(
                    border: false,
                    text: 'Take front photo',
                    onTap: () async {
                      await selectImage(isFrontPhoto: true);
                    },
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Expanded(
                    child: Button(
                  border: false,
                  text: 'Take side photo',
                  onTap: () async {
                    await selectImage(isFrontPhoto: false);
                  },
                )),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            _buildViewImage(
              frontPhoto,
              sidePhoto,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
            border: false,
            color: (frontPhoto == null) || (sidePhoto == null)
                ? Utilities.secondaryColor3
                : Utilities.primaryColor,
            text: canRetryScan ? 'Retry Scan' : 'Continue',
            onTap: () {
              _showInstructions(frontPhoto, sidePhoto);
            }),
      ),
    );
  }
}
