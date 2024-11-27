import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stitches_africa/config/providers/measurement_providers/measurement_providers.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/user_measurement_model.dart';
import 'package:stitches_africa/views/components/custom_textfield.dart';

class MeasurmentsList extends ConsumerStatefulWidget {
  final Stream<UserMeasurementModel> getUserMeasurementStream;

  const MeasurmentsList({
    super.key,
    required this.getUserMeasurementStream,
  });

  @override
  ConsumerState<MeasurmentsList> createState() => _MeasurmentsListState();
}

class _MeasurmentsListState extends ConsumerState<MeasurmentsList> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    // Dispose of all controllers when the widget is removed
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.getUserMeasurementStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child:
                  CircularProgressIndicator(color: Utilities.backgroundColor));
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred'),
          );
        }
        final UserMeasurementModel measurementData = snapshot.data!;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                context: context,
                title: 'Volume Parameters',
                parameters: measurementData.volumeParams.toJson(),
              ),
              SizedBox(height: 20.h),
              _buildSection(
                context: context,
                title: 'Side Parameters',
                parameters: measurementData.sideParams.toJson(),
              ),
              SizedBox(height: 20.h),
              _buildSection(
                context: context,
                title: 'Front Parameters',
                parameters: measurementData.frontParams.toJson(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      {required BuildContext context,
      required String title,
      required Map<String, dynamic> parameters}) {
    final updatedFields = ref.watch(updatedFieldsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 16.sp,
              color: Utilities.secondaryColor,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 20.h),
        ...parameters.entries.map((entry) {
          final key = entry.key;
          final fieldName = _convertToReadableText(key);
          final fieldValue = entry.value.toString();

          // Initialize the controller if not already created
          _controllers.putIfAbsent(
              key, () => TextEditingController(text: fieldValue));

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      fieldName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16.spMin,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100.w,
                    height: 20.h,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 70.w,
                          maxWidth: 100.w,
                        ),
                        child: MeasurementTextField(
                          controller: _controllers[key]!,
                          obscureText: false,
                          onChanged: (value) {
                            // Handle updates dynamically
                            if (kDebugMode) {
                              print('Updated $key: $value');
                            }
                            ref
                                .read(updatedFieldsProvider.notifier)
                                .update((state) {
                              final updatedState =
                                  Map<String, dynamic>.from(state);
                              updatedState[key] = double.tryParse(value) ??
                                  value; // Update the value
                              return updatedState;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              SizedBox(
                width: 75.w,
                child: const Divider(
                  thickness: 0.5,
                  color: Utilities.secondaryColor2,
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  String _convertToReadableText(String key) {
    return key
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .trim()
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
