import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/components/upload_media_widget.dart';
import 'package:stitches_africa/views/widgets/media/fullscreeen_image.dart';
import 'package:toastification/toastification.dart';

class PersonalInformation extends ConsumerStatefulWidget {
  final bool? isToUpdateInfo;
  const PersonalInformation({super.key, this.isToUpdateInfo});

  @override
  ConsumerState<PersonalInformation> createState() =>
      _PersonalInformationState();
}

class _PersonalInformationState extends ConsumerState<PersonalInformation> {
  ShowToasitification showToasitification = ShowToasitification();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  // Error variables
  String? fullNameError;
  String? dayError;
  String? monthError;
  String? yearError;

  bool _validateFields() {
    setState(() {
      // Reset error texts
      fullNameError =
          fullNameController.text.isEmpty ? 'This field is required' : null;
      dayError = dayController.text.isEmpty ? 'This field is required' : null;
      monthError =
          monthController.text.isEmpty ? 'This field is required' : null;
      yearError = yearController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return fullNameError == null &&
        dayError == null &&
        monthError == null &&
        yearError == null;
  }

  void _showDayPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        color: Utilities.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 190.h,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.h,
                onSelectedItemChanged: (index) {
                  setState(() {
                    dayController.text = (index + 1).toString();
                  });
                },
                children: List<Widget>.generate(
                  31,
                  (index) => Text((index + 1).toString()),
                ),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Utilities.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        color: Utilities.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 190.h,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.h,
                onSelectedItemChanged: (index) {
                  setState(() {
                    monthController.text = (index + 1).toString();
                  });
                },
                children: List<Widget>.generate(
                  12,
                  (index) => Text((index + 1).toString()),
                ),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Utilities.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showYearPicker() {
    final currentYear = DateTime.now().year;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        color: Utilities.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 190.h,
              child: CupertinoPicker(
                backgroundColor: Colors.white,
                itemExtent: 32.h,
                onSelectedItemChanged: (index) {
                  setState(() {
                    yearController.text = (currentYear - index).toString();
                  });
                },
                children: List<Widget>.generate(
                  100,
                  (index) => Text((currentYear - index).toString()),
                ),
              ),
            ),
            CupertinoButton(
              child: const Text(
                'Select',
                style: TextStyle(color: Utilities.primaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String fullName = ref.watch(fullNameProvider);
    String day = ref.watch(dayProvider);
    String month = ref.watch(monthProvider);
    String year = ref.watch(yearProvider);
    String faceImage = ref.watch(faceImageProvider);
    String identityImage = ref.watch(identityProvider);

    if (fullName != '') {
      fullNameController.text = fullName;
      dayController.text = day;
      monthController.text = month;
      yearController.text = year;
    }
    return Scaffold(
      backgroundColor: Utilities.backgroundColor,
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
        leading: GestureDetector(
          onTap: () {
            context.pop();
          },
          child: Transform.flip(
            flipX: true,
            child: const Icon(
              FluentSystemIcons.ic_fluent_ios_chevron_right_filled,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                'PERSONAL INFORMATION',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  //letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Help us verify your identity by sharing some basic information and a photo.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: fullNameController,
                hintText: 'FULL NAME',
                obscureText: false,
                errorText: fullNameError,
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showDayPicker,
                      child: AbsorbPointer(
                        child: MyTextField(
                          controller: dayController,
                          hintText: 'Day',
                          obscureText: false,
                          errorText: dayError,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showMonthPicker,
                      child: AbsorbPointer(
                        child: MyTextField(
                          controller: monthController,
                          hintText: 'Month',
                          obscureText: false,
                          errorText: monthError,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _showYearPicker,
                      child: AbsorbPointer(
                        child: MyTextField(
                          controller: yearController,
                          hintText: 'Year',
                          obscureText: false,
                          errorText: yearError,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.h,
              ),
              UploadMediaWidget(
                saveImage: (imageUrl) {
                  ref.read(faceImageProvider.notifier).state = imageUrl!;
                },
                isCamera: true,
                iconPath: 'assets/icons/id-user.svg',
                imageHeight: 100.h,
                uploadMultipleImages: false,
                text1: 'Take a clear photo of your face',
                text3: 'Supported format: .png, .jpg, .jpeg',
              ),
              SizedBox(
                height: 10.h,
              ),
              if (faceImage != '')
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
                              builder: (context) => FullScreenImage(
                                imageUrl: faceImage,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: faceImage,
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CachedNetworkImage(
                              imageUrl: faceImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.primaryColor),
                              ),
                            ),
                          ),
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
                height: 25.h,
              ),
              UploadMediaWidget(
                saveImage: (imageUrl) {
                  ref.read(identityProvider.notifier).state = imageUrl!;
                },
                imageHeight: 100.h,
                uploadMultipleImages: false,
                text1: 'Upload an ID document to verify your identity.',
                text3:
                    '(NIN card, passport, driver’s license)\nSupported format: .png, .jpg, .jpeg',
              ),
              SizedBox(
                height: 10.h,
              ),
              if (identityImage != '')
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
                              builder: (context) => FullScreenImage(
                                imageUrl: identityImage,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: faceImage,
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CachedNetworkImage(
                              imageUrl: identityImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                    color: Utilities.primaryColor),
                              ),
                            ),
                          ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 40.h,
        elevation: 0,
        color: Utilities.backgroundColor,
        padding: EdgeInsets.zero,
        child: Button(
            border: false,
            text: 'Continue',
            onTap: () {
              if (_validateFields() && identityImage != '') {
                ref.read(fullNameProvider.notifier).state =
                    fullNameController.text;
                ref.read(dayProvider.notifier).state = dayController.text;
                ref.read(monthProvider.notifier).state = monthController.text;
                ref.read(yearProvider.notifier).state = yearController.text;
                context.pushNamed('verifyTailorAddressScreen');
              } else if (_validateFields() && (identityImage == '')) {
                showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.error,
                    title: 'Media not uploaded');
              }
            }),
      ),
    );
  }
}
