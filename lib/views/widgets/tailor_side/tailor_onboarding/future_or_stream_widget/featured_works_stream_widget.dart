// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/config/providers/upload_media_providers/upload_media_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_side/tailor_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/dialogs/alert_dialog.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_onboarding/tailor_featured_works_widget.dart';
import 'package:toastification/toastification.dart';

class FeaturedWorksStreamWidget extends ConsumerStatefulWidget {
  final Stream<TailorModel?> getTailorModel;
  const FeaturedWorksStreamWidget({super.key, required this.getTailorModel});

  @override
  ConsumerState<FeaturedWorksStreamWidget> createState() =>
      _FeaturedWorksStreamWidgetState();
}

class _FeaturedWorksStreamWidgetState
    extends ConsumerState<FeaturedWorksStreamWidget> {
  final ShowToasitification showToasitification = ShowToasitification();
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  List<String> mediaPaths = [];
  UploadTask? uploadTask;
  String mediaUrl = '';
  double uploadProgress = 0.0;
  int totalUploads = 0;

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  void cancelUpload() {
    if (uploadTask != null) {
      uploadTask!.cancel();
      ref.read(numberOfUploadsCompletedProvider.notifier).state = 0;
    }
  }

  Future<void> uploadImagesHandler() async {
    ImagePicker imagePicker = ImagePicker();
    List<XFile> files = await imagePicker.pickMultiImage();

    if (files.isEmpty) {
      showToasitification.showToast(
        context: context,
        toastificationType: ToastificationType.info,
        title: 'Upload Cancelled',
      );
      return;
    }

    try {
      totalUploads = files.length;
      for (XFile file in files) {
        String uniqueFileName =
            DateTime.now().millisecondsSinceEpoch.toString();

        // Get reference to storage root
        Reference referenceRoot = FirebaseStorage.instance.ref();

        // Create a folder for each upload, e.g., using email or tailor brand
        Reference referenceDirImages;
        String emailAddress = FirebaseAuth.instance.currentUser!.email!;
        referenceDirImages = referenceRoot.child('$emailAddress media');

        // Sub folder for images
        Reference referenceSubImages = referenceDirImages.child('images');

        // Reference for each image upload
        Reference referenceImageToUpload =
            referenceSubImages.child(uniqueFileName);

        if (Platform.isIOS) {
          showCupertinoDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: const Text(
                    'Uploading Media...',
                    style: TextStyle(),
                  ),
                  content: StreamBuilder<TaskSnapshot>(
                      stream: referenceImageToUpload
                          .putFile(File(file.path))
                          .snapshotEvents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final taskSnapshot = snapshot.data!;
                          final progress = taskSnapshot.bytesTransferred /
                              (taskSnapshot.totalBytes != 0
                                  ? taskSnapshot.totalBytes
                                  : 1);
                          uploadProgress = progress;

                          if (kDebugMode) {
                            print(progress);
                          }
                        }
                        String uploadProgressText =
                            uploadProgress.isNaN || uploadProgress.isInfinite
                                ? '0%'
                                : '${(uploadProgress * 100).round()}%';
                        return Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  LinearPercentIndicator(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.w),
                                    width: 120.w,
                                    lineHeight: 5.h,
                                    percent: uploadProgress,
                                    backgroundColor: Utilities.secondaryColor3,
                                    progressColor: Utilities.primaryColor,
                                    animation: true,
                                    trailing: Text(
                                      uploadProgressText,
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 3.h,
                                  ),
                                  Text(
                                    '${ref.read(numberOfUploadsCompletedProvider)}/$totalUploads completed',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                  actions: <Widget>[
                    CupertinoDialogAction(
                        onPressed: () {
                          cancelUpload();
                          Navigator.pop(context);
                          return;
                        },
                        isDestructiveAction: true,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ))
                  ],
                );
              });
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  color: Utilities.backgroundColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Uploading Media...'),
                      SizedBox(height: 0.h),
                      StreamBuilder<TaskSnapshot>(
                          stream: referenceImageToUpload
                              .putFile(File(file.path))
                              .snapshotEvents,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final taskSnapshot = snapshot.data!;
                              final progress = taskSnapshot.bytesTransferred /
                                  (taskSnapshot.totalBytes != 0
                                      ? taskSnapshot.totalBytes
                                      : 1);
                              uploadProgress = progress;

                              if (kDebugMode) {
                                print(progress);
                              }
                            }
                            String uploadProgressText = uploadProgress.isNaN ||
                                    uploadProgress.isInfinite
                                ? '0%'
                                : '${(uploadProgress * 100).round()}%';
                            return Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      LinearPercentIndicator(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.w),
                                        width: 120.w,
                                        lineHeight: 5.h,
                                        percent: uploadProgress,
                                        backgroundColor:
                                            Utilities.secondaryColor3,
                                        progressColor: Utilities.primaryColor,
                                        animation: true,
                                        trailing: Text(
                                          uploadProgressText,
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        '${ref.read(numberOfUploadsCompletedProvider)}/$totalUploads completed',
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                      SizedBox(
                        height: 4.h,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Button(
                            border: false,
                            text: 'Cancel',
                            onTap: () {
                              cancelUpload();
                              Navigator.pop(context);
                              return;
                            }),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }

        // Store the file and track progress
        uploadTask = referenceImageToUpload.putFile(File(file.path));

        Stream<TaskSnapshot> taskSnapshotStream = uploadTask!.snapshotEvents;
        taskSnapshotStream.listen((TaskSnapshot snapshot) {
          uploadProgress = snapshot.bytesTransferred /
              (snapshot.totalBytes != 0 ? snapshot.totalBytes : 1);
        });

        await uploadTask;

        // Success: Get download URL for each image
        String imageUrl = await referenceImageToUpload.getDownloadURL();
        mediaPaths.add(imageUrl);

        // update the upload prgress
        ref.read(numberOfUploadsCompletedProvider.notifier).state =
            ref.read(numberOfUploadsCompletedProvider) + 1;

        if (kDebugMode) {
          print('Image uploaded: $imageUrl');
        }
        Navigator.pop(context);
      }

      //ref.read(mediaPathsProvider.notifier).state = mediaPaths;
      ref.read(numberOfUploadsCompletedProvider.notifier).state = 0;

      return;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('Error uploading media: ${e.code}');
      }
      if (e.code.contains('canceled')) {
        showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.info,
          title: e.code,
        );
        return;
      }

      showToasitification.showToast(
        context: context,
        toastificationType: ToastificationType.error,
        title: 'Error Uploading Media',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TailorModel?>(
        stream: widget.getTailorModel,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Utilities.backgroundColor));
          } else if (snapshot.hasError) {
            if (Platform.isIOS) {
              return IOSAlertDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.${snapshot.error}',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  },
                  isDefaultAction1: true,
                  isDestructiveAction1: false);
            } else {
              return AndriodAleartDialogWidget(
                  title: 'Error',
                  content:
                      'Unable to connect to the server. Please check your internet connection and try again.',
                  actionButton1: 'Ok',
                  actionButton1OnTap: () {
                    Navigator.pop(context);
                  });
            }
          }

          final tailorModel = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                tailorModel.brandName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  //letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                height: 525.h,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tailorModel.featuredWorks.length + 1,
                    itemBuilder: (context, index) {
                      if (index + 1 != tailorModel.featuredWorks.length + 1) {
                        return TailorSideFeaturedWorksWidget(
                            imageUrl: tailorModel.featuredWorks[index]);
                      } else {
                        return GestureDetector(
                          onTap: () async {
                            await uploadImagesHandler().then((_) async {
                              await firebaseFirestoreFunctions
                                  .addImagesFromFeaturedWorks(
                                      getCurrentUserId(), mediaPaths);

                              showToasitification.showToast(
                                context: context,
                                toastificationType: ToastificationType.success,
                                title: 'Image(s) added successfully',
                              );
                            });
                          },
                          child: Container(
                              width: 325.w,
                              height: 550.h,
                              decoration: const BoxDecoration(
                                  color: Utilities.secondaryColor2),
                              child: const Icon(
                                FluentSystemIcons.ic_fluent_add_filled,
                                size: 28,
                              )),
                        );
                      }
                    }),
              ),
            ],
          );
        });
  }
}
