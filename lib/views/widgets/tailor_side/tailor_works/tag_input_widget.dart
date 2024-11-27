import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/tailor_works_provider/tailor_works_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class TagInputWidget extends ConsumerStatefulWidget {
  const TagInputWidget({super.key});
  @override
  ConsumerState<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends ConsumerState<TagInputWidget> {
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final List<String> tags = ref.watch(tagsProvider);
    void addTag() {
      String tag = _tagController.text.trim();
      if (tag.isNotEmpty && !tags.contains(tag)) {
        ref.read(tagsProvider.notifier).update((state) {
          List<String> updatedTags = List.from(state); // Copy current list
          updatedTags.add(tag); // Add new tag
          return updatedTags;
        });

        _tagController.clear();
      }
    }

    void removeTag(String tag) {
      ref.read(tagsProvider.notifier).update((state) {
        List<String> updatedTags = List.from(state); // Copy current list
        updatedTags.remove(tag); // remove new tag
        return updatedTags;
      });
    }

    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              child: MyTextField(
                controller: _tagController,
                hintText: 'ENTER TAG',
                onSubmitted: (value) {
                  addTag();
                },
                obscureText: false,
                helperText: 'Tags help customers find your works.',
              ),
            ),
            IconButton(
              icon: const Icon(
                FluentSystemIcons.ic_fluent_add_regular,
                size: 20,
              ),
              onPressed: addTag,
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Display Tags
        Wrap(
          spacing: 8.w,
          children: tags.map((tag) {
            return Chip(
              backgroundColor: Utilities.backgroundColor,
              side: const BorderSide(
                color: Utilities.primaryColor,
              ),
              label: Text(tag),
              labelStyle: TextStyle(
                  color: Utilities.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400),
              deleteIcon: const Icon(
                FluentSystemIcons.ic_fluent_dismiss_regular,
                size: 14,
              ),
              onDeleted: () => removeTag(tag),
            );
          }).toList(),
        ),
      ],
    );
  }
}
