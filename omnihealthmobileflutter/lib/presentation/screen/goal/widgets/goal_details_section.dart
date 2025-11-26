import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/date_picker_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/section_title.dart';

class GoalDetailsSection extends StatelessWidget {
  final GoalTypeEnum? goalType;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<GoalTypeEnum> onGoalTypeChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const GoalDetailsSection({
    super.key,
    required this.goalType,
    required this.startDate,
    required this.endDate,
    required this.onGoalTypeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final goalTypeOptions = GoalTypeEnum.values
        .map((e) => SelectOption(label: e.displayName, value: e))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Goal Details'),
        SizedBox(height: AppSpacing.md.h),
        SingleSelectBox<GoalTypeEnum>(
          label: 'Goal Type',
          value: goalType,
          options: goalTypeOptions,
          onChanged: onGoalTypeChanged,
          required: true,
          placeholder: 'Select goal type',
        ),
        SizedBox(height: AppSpacing.md.h),
        Row(
          children: [
            Expanded(
              child: DatePickerField(
                label: 'Start Date',
                value: startDate,
                onChanged: onStartDateChanged,
                required: true,
              ),
            ),
            SizedBox(width: AppSpacing.md.w),
            Expanded(
              child: DatePickerField(
                label: 'End Date',
                value: endDate,
                onChanged: onEndDateChanged,
                required: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
