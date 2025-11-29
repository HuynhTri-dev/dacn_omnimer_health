import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/multi_select_box.dart';

/// Widget cho phần Health Status
class HealthStatusSection extends StatelessWidget {
  final TextEditingController restingHeartRateController;
  final TextEditingController bloodPressureSystolicController;
  final TextEditingController bloodPressureDiastolicController;
  final TextEditingController cholesterolTotalController;
  final TextEditingController cholesterolHdlController;
  final TextEditingController cholesterolLdlController;
  final TextEditingController bloodSugarController;

  // Detailed Health Status Fields
  final List<String> knownConditionsSelected;
  final Map<String, String> knownConditionsDetails;
  final List<String> knownConditionsOptions;
  final ValueChanged<List<String>> onKnownConditionsSelectionChanged;
  final Function(String, String) onKnownConditionsDetailChanged;

  final List<String> painLocationsSelected;
  final Map<String, String> painLocationsDetails;
  final List<String> painLocationsOptions;
  final ValueChanged<List<String>> onPainLocationsSelectionChanged;
  final Function(String, String) onPainLocationsDetailChanged;

  final List<String> jointIssuesSelected;
  final Map<String, String> jointIssuesDetails;
  final List<String> jointIssuesOptions;
  final ValueChanged<List<String>> onJointIssuesSelectionChanged;
  final Function(String, String) onJointIssuesDetailChanged;

  final List<String> injuriesSelected;
  final Map<String, String> injuriesDetails;
  final List<String> injuriesOptions;
  final ValueChanged<List<String>> onInjuriesSelectionChanged;
  final Function(String, String) onInjuriesDetailChanged;

  final List<String> abnormalitiesSelected;
  final Map<String, String> abnormalitiesDetails;
  final List<String> abnormalitiesOptions;
  final ValueChanged<List<String>> onAbnormalitiesSelectionChanged;
  final Function(String, String) onAbnormalitiesDetailChanged;

  final TextEditingController notesController;

  final bool hasMedicalData;
  final ValueChanged<bool> onHasMedicalDataChanged;

  const HealthStatusSection({
    super.key,
    required this.restingHeartRateController,
    required this.bloodPressureSystolicController,
    required this.bloodPressureDiastolicController,
    required this.cholesterolTotalController,
    required this.cholesterolHdlController,
    required this.cholesterolLdlController,
    required this.bloodSugarController,

    required this.knownConditionsSelected,
    required this.knownConditionsDetails,
    required this.knownConditionsOptions,
    required this.onKnownConditionsSelectionChanged,
    required this.onKnownConditionsDetailChanged,

    required this.painLocationsSelected,
    required this.painLocationsDetails,
    required this.painLocationsOptions,
    required this.onPainLocationsSelectionChanged,
    required this.onPainLocationsDetailChanged,

    required this.jointIssuesSelected,
    required this.jointIssuesDetails,
    required this.jointIssuesOptions,
    required this.onJointIssuesSelectionChanged,
    required this.onJointIssuesDetailChanged,

    required this.injuriesSelected,
    required this.injuriesDetails,
    required this.injuriesOptions,
    required this.onInjuriesSelectionChanged,
    required this.onInjuriesDetailChanged,

    required this.abnormalitiesSelected,
    required this.abnormalitiesDetails,
    required this.abnormalitiesOptions,
    required this.onAbnormalitiesSelectionChanged,
    required this.onAbnormalitiesDetailChanged,

    required this.notesController,
    required this.hasMedicalData,
    required this.onHasMedicalDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.favorite,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Health Status',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),

          // Warning / Confirmation Section
          Container(
            padding: EdgeInsets.all(AppSpacing.sm.w),
            decoration: BoxDecoration(
              color: hasMedicalData
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasMedicalData ? Colors.green : Colors.orange,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasMedicalData
                          ? Icons.check_circle_outline
                          : Icons.warning_amber_rounded,
                      color: hasMedicalData ? Colors.green : Colors.orange,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        hasMedicalData
                            ? 'Medical data enabled'
                            : 'Requires medical device or expert',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasMedicalData ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'Only enter this data if you have a measuring device or information from a medical professional.',
                  style: textTheme.bodySmall,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Checkbox(
                      value: hasMedicalData,
                      onChanged: (value) {
                        onHasMedicalDataChanged(value ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          onHasMedicalDataChanged(!hasMedicalData);
                        },
                        child: Text(
                          'I have valid medical data',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Animated visibility for form fields
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSpacing.md.h),
                CustomTextField(
                  label: 'Resting Heart Rate (bpm)',
                  controller: restingHeartRateController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSpacing.md.h),

                // Blood Pressure subsection
                Text(
                  'Blood Pressure',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Systolic',
                        controller: bloodPressureSystolicController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: CustomTextField(
                        label: 'Diastolic',
                        controller: bloodPressureDiastolicController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md.h),

                // Cholesterol subsection
                Text(
                  'Cholesterol',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                CustomTextField(
                  label: 'Total',
                  controller: cholesterolTotalController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSpacing.sm.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'HDL',
                        controller: cholesterolHdlController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: CustomTextField(
                        label: 'LDL',
                        controller: cholesterolLdlController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md.h),
                CustomTextField(
                  label: 'Blood Sugar (mg/dL)',
                  controller: bloodSugarController,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: AppSpacing.md.h),

                // Detailed Health Status Fields
                _buildDetailedMultiSelect(
                  label: 'Known Conditions',
                  selectedItems: knownConditionsSelected,
                  itemDetails: knownConditionsDetails,
                  options: knownConditionsOptions,
                  onSelectionChanged: onKnownConditionsSelectionChanged,
                  onDetailChanged: onKnownConditionsDetailChanged,
                ),
                SizedBox(height: AppSpacing.md.h),

                _buildDetailedMultiSelect(
                  label: 'Pain Locations',
                  selectedItems: painLocationsSelected,
                  itemDetails: painLocationsDetails,
                  options: painLocationsOptions,
                  onSelectionChanged: onPainLocationsSelectionChanged,
                  onDetailChanged: onPainLocationsDetailChanged,
                ),
                SizedBox(height: AppSpacing.md.h),

                _buildDetailedMultiSelect(
                  label: 'Joint Issues',
                  selectedItems: jointIssuesSelected,
                  itemDetails: jointIssuesDetails,
                  options: jointIssuesOptions,
                  onSelectionChanged: onJointIssuesSelectionChanged,
                  onDetailChanged: onJointIssuesDetailChanged,
                ),
                SizedBox(height: AppSpacing.md.h),

                _buildDetailedMultiSelect(
                  label: 'Injuries',
                  selectedItems: injuriesSelected,
                  itemDetails: injuriesDetails,
                  options: injuriesOptions,
                  onSelectionChanged: onInjuriesSelectionChanged,
                  onDetailChanged: onInjuriesDetailChanged,
                ),
                SizedBox(height: AppSpacing.md.h),

                _buildDetailedMultiSelect(
                  label: 'Abnormalities',
                  selectedItems: abnormalitiesSelected,
                  itemDetails: abnormalitiesDetails,
                  options: abnormalitiesOptions,
                  onSelectionChanged: onAbnormalitiesSelectionChanged,
                  onDetailChanged: onAbnormalitiesDetailChanged,
                ),
                SizedBox(height: AppSpacing.md.h),

                CustomTextField(
                  label: 'Notes',
                  controller: notesController,
                  maxLines: 3,
                ),
              ],
            ),
            crossFadeState: hasMedicalData
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMultiSelect({
    required String label,
    required List<String> selectedItems,
    required Map<String, String> itemDetails,
    required List<String> options,
    required ValueChanged<List<String>> onSelectionChanged,
    required Function(String, String) onDetailChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MultiSelectBox<String>(
          label: label,
          value: selectedItems,
          options: options.map((e) => MultiSelectItem(e, e)).toList(),
          onChanged: onSelectionChanged,
          placeholder: 'Select $label',
        ),
        if (selectedItems.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm.h),
          ...selectedItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: AppSpacing.sm.h,
                left: AppSpacing.md.w,
              ),
              child: CustomTextField(
                key: ValueKey('detail_${label}_$item'),
                label: 'Details for $item',
                value: itemDetails[item],
                onChanged: (value) => onDetailChanged(item, value),
                placeholder: 'Enter details...',
              ),
            );
          }),
        ],
      ],
    );
  }
}
