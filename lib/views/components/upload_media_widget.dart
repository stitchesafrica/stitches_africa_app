// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/config/providers/upload_media_providers/upload_media_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:toastification/toastification.dart';

class UploadMediaWidget extends ConsumerStatefulWidget {
  final String text1;
  final String? text2;
  final String text3;
  final String? iconPath;
  final bool? isCamera;
  final double imageHeight;
  final bool uploadMultipleImages;
  final Function(String? imageUrl)? saveImage;
  const UploadMediaWidget({
    super.key,
    required this.text1,
    this.text2,
    required this.text3,
    this.iconPath,
    this.isCamera,
    required this.imageHeight,
    required this.uploadMultipleImages,
    this.saveImage,
  });

  @override
  ConsumerState<UploadMediaWidget> createState() => _UploadMediaWidgetState();
}

class _UploadMediaWidgetState extends ConsumerState<UploadMediaWidget> {
  @override
  Widget build(BuildContext context) {
    ShowToasitification showToasitification = ShowToasitification();
    UploadTask? uploadTask;
    String mediaUrl = '';
    double uploadProgress = 0.0;
    int totalUploads = 0;

    void cancelUpload() {
      if (uploadTask != null) {
        uploadTask!.cancel();
      }
    }

    Future<void> uploadImageHandler() async {
      ImagePicker imagePicker = ImagePicker();
      XFile? file = await imagePicker.pickImage(
          source: widget.isCamera ?? false
              ? ImageSource.camera
              : ImageSource.gallery);

      if (file == null) {
        showToasitification.showToast(
          context: context,
          toastificationType: ToastificationType.info,
          title: 'Upload Cancelled',
        );
        return;
      }

      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Get a reference to the storage root
      Reference referenceRoot = FirebaseStorage.instance.ref();

      // Create a folder of that reference
      Reference referenceDirImages;
      String emailAddress = FirebaseAuth.instance.currentUser!.email!;
      referenceDirImages = referenceRoot.child('$emailAddress media');
      // Create a sub folder
      Reference referenceSubImages = referenceDirImages.child('images');

      // Create a reference for the image to be stored -- name of the file you want to save it as
      Reference referenceImageToUpload =
          referenceSubImages.child(uniqueFileName);
      try {
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
                            print("progress:$progress");
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
                              LinearPercentIndicator(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                            ],
                          ),
                        );
                      }),
                  actions: <Widget>[
                    CupertinoDialogAction(
                        onPressed: () {
                          cancelUpload();
                          Navigator.pop(context);
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
                      Consumer(
                        builder: (context, ref, child) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.primaryColor));
                        },
                      ),
                      SizedBox(height: 20.h),
                      const Text('Uploading Media...'),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // Store file
        UploadTask uploadTask = referenceImageToUpload.putFile(File(file.path));
        // Get the task stream to track the upload progress
        Stream<TaskSnapshot> taskSnapshotStream = uploadTask.snapshotEvents;
        taskSnapshotStream.listen((TaskSnapshot snapshot) {
          // setState(() {
          uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          // });
        });
        await uploadTask;
        Navigator.of(context).pop();

        // Success: get the download URL
        mediaUrl = await referenceImageToUpload.getDownloadURL();
        widget.saveImage!(mediaUrl);
        //ref.read(tailorLogoProvider.notifier).state = mediaUrl;
        if (kDebugMode) {
          print('Image uploaded: $mediaUrl');
        }
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
        rethrow;
      }
    }

    Future<void> uploadImagesHandler() async {
      List<String> mediaPaths = [];
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
                              String uploadProgressText =
                                  uploadProgress.isNaN ||
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
        ref.read(mediaPathsProvider.notifier).state = [];
        ref.read(mediaPathsProvider.notifier).state = mediaPaths;
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

    return DottedBorder(
      color: Utilities.primaryColor,
      dashPattern: [6.w, 3.w, 5.w, 3.w],
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            // or use Expanded here
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      widget.uploadMultipleImages
                          ? await uploadImagesHandler()
                          : await uploadImageHandler();
                    },
                    child: SvgPicture.asset(
                      widget.iconPath ?? 'assets/icons/upload_icon.svg',
                      height: widget.imageHeight,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  RichText(
                    textAlign:
                        TextAlign.center, // Align text within available width
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Utilities.primaryColor,
                      ),
                      children: [
                        TextSpan(text: widget.text1),
                        TextSpan(
                          text: widget.text2,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    widget.text3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Utilities.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
