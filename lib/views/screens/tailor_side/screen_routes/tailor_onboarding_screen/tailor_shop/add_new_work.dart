import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_onboarding_providers/tailor_onboarding_providers.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/components/upload_media_widget.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_works/tag_input_widget.dart';
import 'package:toastification/toastification.dart';

enum GenderCategory { men, women, kids }

GenderCategory? _selectedCategory = GenderCategory.men;

class AddNewWork extends ConsumerStatefulWidget {
  const AddNewWork({super.key});

  @override
  ConsumerState<AddNewWork> createState() => _AddNewWorkState();
}

class _AddNewWorkState extends ConsumerState<AddNewWork> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification showToasitification = ShowToasitification();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String category = 'men';

  // Error variables
  String? titleError;
  String? priceError;
  String? descriptionError;

  String generateRandomDocId({int length = 20}) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join('');
  }

  bool _validateFields() {
    setState(() {
      // Reset error texts
      titleError =
          titleController.text.isEmpty ? 'This field is required' : null;
      priceError =
          priceController.text.isEmpty ? 'This field is required' : null;
      descriptionError =
          descriptionController.text.isEmpty ? 'This field is required' : null;
    });
    // Return true if all fields are filled, otherwise false
    return titleError == null && priceError == null && descriptionError == null;
  }

  String getCurrentUserId() {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    String userID = currentUser.uid;
    return userID;
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String title = ref.watch(titleProvider);
    String price = ref.watch(priceProvider);
    String description = ref.watch(descriptionProvider);

    if (title != '') {
      titleController.text = title;
      priceController.text = price;
      descriptionController.text = description;
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
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10.h,
              ),
              Text(
                'ADD NEW WORK',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22.sp,
                  // letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 25.h,
              ),
              MyTextField(
                controller: titleController,
                hintText: 'TITLE',
                obscureText: false,
                errorText: titleError,
                onSubmitted: (value) {
                  ref.read(titleProvider.notifier).state = value;
                },
                // autofillHints: const [AutofillHints.streetAddressLevel1],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: priceController,
                      hintText: 'PRICE',
                      obscureText: false,
                      errorText: priceError,
                      textType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      onSubmitted: (value) {
                        ref.read(priceProvider.notifier).state = value;
                      },
                      // autofillHints: const [AutofillHints.streetAddressLevel1],
                    ),
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Text(
                    'USD',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.w,
              ),
              SizedBox(
                height: 150.h,
                child: DescriptionTextField(
                  controller: descriptionController,
                  hintText: 'WORK DESCRIPTION',
                  errorText: descriptionError,
                  onChanged: (value) {
                    ref.read(descriptionProvider.notifier).state = value;
                  },
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                'CHOOSE CATEGORY',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Men',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                leading: Radio<GenderCategory>(
                  activeColor: Utilities.primaryColor,
                  value: GenderCategory.men,
                  groupValue: _selectedCategory,
                  onChanged: (GenderCategory? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Women',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                leading: Radio<GenderCategory>(
                  activeColor: Utilities.primaryColor,
                  value: GenderCategory.women,
                  groupValue: _selectedCategory,
                  onChanged: (GenderCategory? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: const Text(
                  'Kids',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                leading: Radio<GenderCategory>(
                  activeColor: Utilities.primaryColor,
                  value: GenderCategory.kids,
                  groupValue: _selectedCategory,
                  onChanged: (GenderCategory? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              const TagInputWidget(),
              SizedBox(
                height: 20.h,
              ),
              UploadMediaWidget(
                text1: 'Upload your images',
                text3: 'Supported format: .png, .jpg, .jpeg',
                imageHeight: 125.h,
                uploadMultipleImages: true,
              ),
              SizedBox(
                height: 50.h,
              )
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
            text: 'Upload work',
            onTap: () async {
              try {
                if (_validateFields() &&
                    ref.read(mediaPathsProvider).isNotEmpty) {
                  switch (_selectedCategory) {
                    case GenderCategory.men:
                      category = 'men';
                      break;
                    case GenderCategory.women:
                      category = 'women';
                      break;
                    case GenderCategory.kids:
                      category = 'kids';
                      break;
                    default:
                      category = 'men';
                  }
                  if (double.tryParse(priceController.text) == null) {
                    throw Error;
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Utilities.backgroundColor));
                        });
                    await firebaseFirestoreFunctions
                        .createTailoWork(
                            getCurrentUserId(),
                            generateRandomDocId(),
                            ref.read(titleProvider),
                            double.parse(ref.read(priceProvider)),
                            ref.read(descriptionProvider),
                            category,
                            ref.read(tagsProvider),
                            ref.read(mediaPathsProvider))
                        .then((_) {
                      ref.invalidate(titleProvider);
                      ref.invalidate(priceProvider);
                      ref.invalidate(descriptionProvider);
                      Navigator.pop(context);
                      context.pop(context);
                    });
                  }
                } else if (_validateFields() &&
                    ref.read(mediaPathsProvider).isEmpty) {
                  showToasitification.showToast(
                      context: context,
                      toastificationType: ToastificationType.error,
                      title: 'Images not uploaded');
                }
              } catch (e) {
                showToasitification.showToast(
                    context: context,
                    toastificationType: ToastificationType.error,
                    title: 'Invalid price');
                rethrow;
              }
            }),
      ),
    );
  }
}
