import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/tailor_work_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/components/button.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';
import 'package:stitches_africa/views/components/toastification.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_works/future_or_stream_widget.dart/work_images_stream.dart';
import 'package:stitches_africa/views/widgets/tailor_side/tailor_works/tag_input_widget.dart';
import 'package:toastification/toastification.dart';

enum GenderCategory { men, women, kids }

GenderCategory? _selectedCategory = GenderCategory.men;

class EditWork extends ConsumerStatefulWidget {
  final QueryDocumentSnapshot data;
  const EditWork({super.key, required this.data});

  @override
  ConsumerState<EditWork> createState() => _EditWorkState();
}

class _EditWorkState extends ConsumerState<EditWork> {
  final FirebaseFirestoreFunctions firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();
  final ShowToasitification showToasitification = ShowToasitification();
  late TextEditingController titleController = TextEditingController();
  late TextEditingController priceController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late String category;
  late List<String> tags;
  late List<String> images;

  // Error variables
  String? titleError;
  String? priceError;
  String? descriptionError;

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

  Stream<TailorWorkModel?> getTailorWorkModel() {
    return FirebaseFirestore.instance
        .collection('tailor_works')
        .doc(widget.data['product_id'])
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return TailorWorkModel.fromDocument(snapshot.data()!);
      }
      return null;
    });
  }

  @override
  void initState() {
    super.initState();

    titleController.text = widget.data['title'];
    priceController.text = widget.data['price'].toString();
    descriptionController.text = widget.data['description'];
    category = widget.data['category'];
    tags = List<String>.from(widget.data['tags']);
    images = List<String>.from(widget.data['images']);
    switch (category) {
      case 'men':
        _selectedCategory = GenderCategory.men;
        break;
      case 'women':
        _selectedCategory = GenderCategory.women;
        break;
      case 'kids':
        _selectedCategory = GenderCategory.kids;
        break;
    }
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

    // if (title != '') {
    //   titleController.text = title;
    //   priceController.text = price;
    //   descriptionController.text = description;
    // }

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
                'EDIT WORK',
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
                  // setState(() {
                  //   titleController.text = value;
                  // });
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
                        setState(() {});
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
              WorkImagesStream(getTailorModel: getTailorWorkModel())
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
            text: 'Save changes',
            onTap: () async {
              try {
                if (_validateFields()) {
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
                        .updateTailorWork(
                            getCurrentUserId(),
                            widget.data['product_id'],
                            titleController.text,
                            double.parse(priceController.text),
                            descriptionController.text,
                            category,
                            ref.read(tagsProvider))
                        .then((_) {
                      Navigator.pop(context);
                      context.pop(context);
                    });
                  }
                }
              } catch (e) {
                print(e);
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
