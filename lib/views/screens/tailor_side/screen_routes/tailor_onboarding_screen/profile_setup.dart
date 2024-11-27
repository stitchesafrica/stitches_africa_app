import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
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

class ProfileSetup extends ConsumerStatefulWidget {
  const ProfileSetup({super.key});

  @override
  ConsumerState<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends ConsumerState<ProfileSetup> {
  ShowToasitification showToasitification = ShowToasitification();
  final TextEditingController tailorBrandNameController =
      TextEditingController();
  final TextEditingController tailorTaglineController = TextEditingController();

  // Error variables
  String? tailorBrandNameError;
  String? tailorTaglineError;

  bool _validateFields() {
    setState(() {
      // Reset error texts
      tailorBrandNameError = tailorBrandNameController.text.isEmpty
          ? 'This field is required'
          : null;
      tailorTaglineError = tailorTaglineController.text.isEmpty
          ? 'This field is required'
          : null;
    });
    // Return true if all fields are filled, otherwise false
    return tailorBrandNameError == null && tailorTaglineError == null;
  }

  @override
  Widget build(BuildContext context) {
    String tailorBrandName = ref.watch(tailorBrandNameProvider);
    String tailorTagline = ref.watch(tailorTaglineProvider);
    String tailorLogo = ref.watch(tailorLogoProvider);

    if (tailorBrandName != '') {
      tailorBrandNameController.text = tailorBrandName;
      tailorTaglineController.text = tailorTagline;
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
                'PROFILE SETUP',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Set up your profile to showcase your brand and make a lasting impression.',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: tailorBrandNameController,
                hintText: 'Brand Name (e.g., Yomi Casuals)',
                obscureText: false,
                errorText: tailorBrandNameError,
              ),
              SizedBox(
                height: 20.h,
              ),
              MyTextField(
                controller: tailorTaglineController,
                hintText: 'Tagline (e.g.Open Doors To A World Of Fashion)',
                obscureText: false,
                errorText: tailorTaglineError,
              ),
              SizedBox(
                height: 25.h,
              ),
              UploadMediaWidget(
                saveImage: (imageUrl) {
                  ref.read(tailorLogoProvider.notifier).state = imageUrl!;
                },
                imageHeight: 125.h,
                uploadMultipleImages: false,
                text1: 'Upload your logo or ',
                text2: 'provide a URL',
                text3: 'Supported format: .png, .jpg, .jpeg',
              ),
              SizedBox(
                height: 10.h,
              ),
              if (tailorLogo != '')
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
                                imageUrl: tailorLogo,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: tailorLogo,
                          child: SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: CachedNetworkImage(
                              imageUrl: tailorLogo,
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
                const SizedBox.shrink()
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
              if (_validateFields() && tailorLogo != '') {
                ref.read(tailorBrandNameProvider.notifier).state =
                    tailorBrandNameController.text;
                ref.read(tailorTaglineProvider.notifier).state =
                    tailorTaglineController.text;
                context.pushNamed('contactInfo');
              } else if (_validateFields() && tailorLogo == '') {
                showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.error,
                    title: 'Logo not uploaded');
              }
            }),
      ),
    );
  }
}
