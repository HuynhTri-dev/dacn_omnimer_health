import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';

/// Widget cho phần Fitness & Physical Performance
class FitnessSection extends StatelessWidget {
  final TextEditingController maxPushUpsController;
  final TextEditingController maxWeightLiftedController;
  final ActivityLevelEnum? selectedActivityLevel;
  final ValueChanged<ActivityLevelEnum?> onActivityLevelChanged;
  final ExperienceLevelEnum? selectedExperienceLevel;
  final ValueChanged<ExperienceLevelEnum?> onExperienceLevelChanged;
  final TextEditingController workoutFrequencyController;

  const FitnessSection({
    super.key,
    required this.maxPushUpsController,
    required this.maxWeightLiftedController,
    required this.selectedActivityLevel,
    required this.onActivityLevelChanged,
    required this.selectedExperienceLevel,
    required this.onExperienceLevelChanged,
    required this.workoutFrequencyController,
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
                  Icons.fitness_center,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Fitness & Physical',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          CustomTextField(
            label: 'Max Push Ups',
            controller: maxPushUpsController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppSpacing.sm.h),
          CustomTextField(
            label: 'Max Weight Lifted (kg)',
            controller: maxWeightLiftedController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: AppSpacing.sm.h),
          SingleSelectBox<ActivityLevelEnum>(
            label: 'Activity Level',
            placeholder: 'Select activity level',
            value: selectedActivityLevel,
            options: ActivityLevelEnum.values
                .map((e) => SelectOption(label: e.displayName, value: e))
                .toList(),
            onChanged: onActivityLevelChanged,
          ),
          SizedBox(height: AppSpacing.sm.h),
          SingleSelectBox<ExperienceLevelEnum>(
            label: 'Experience Level',
            placeholder: 'Select experience level',
            value: selectedExperienceLevel,
            options: ExperienceLevelEnum.values
                .map((e) => SelectOption(label: e.displayName, value: e))
                .toList(),
            onChanged: onExperienceLevelChanged,
          ),
          SizedBox(height: AppSpacing.sm.h),
          CustomTextField(
            label: 'Workout Frequency (days/week)',
            controller: workoutFrequencyController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
