import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/multi_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/section_title.dart';

class FrequencySection extends StatelessWidget {
  final String? frequency;
  final TextEditingController intervalController;
  final List<int> daysOfWeek;
  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<List<int>> onDaysOfWeekChanged;

  const FrequencySection({
    super.key,
    required this.frequency,
    required this.intervalController,
    required this.daysOfWeek,
    required this.onFrequencyChanged,
    required this.onDaysOfWeekChanged,
  });

  @override
  Widget build(BuildContext context) {
    final frequencyOptions = [
      const SelectOption(label: 'Daily', value: 'daily'),
      const SelectOption(label: 'Weekly', value: 'weekly'),
      const SelectOption(label: 'Monthly', value: 'monthly'),
    ];

    final dayOptions = [
      MultiSelectItem(1, 'Mon'),
      MultiSelectItem(2, 'Tue'),
      MultiSelectItem(3, 'Wed'),
      MultiSelectItem(4, 'Thu'),
      MultiSelectItem(5, 'Fri'),
      MultiSelectItem(6, 'Sat'),
      MultiSelectItem(7, 'Sun'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Frequency (Optional)'),
        SizedBox(height: AppSpacing.md.h),
        SingleSelectBox<String>(
          label: 'Frequency',
          value: frequency,
          options: frequencyOptions,
          onChanged: onFrequencyChanged,
          placeholder: 'Select frequency',
        ),
        if (frequency != null) ...[
          SizedBox(height: AppSpacing.md.h),
          CustomTextField(
            label: 'Interval',
            controller: intervalController,
            keyboardType: TextInputType.number,
            placeholder: 'e.g. 1 (every 1 $frequency)',
          ),
          if (frequency == 'weekly') ...[
            SizedBox(height: AppSpacing.md.h),
            MultiSelectBox<int>(
              label: 'Days of Week',
              value: daysOfWeek,
              options: dayOptions,
              onChanged: onDaysOfWeekChanged,
            ),
          ],
        ],
      ],
    );
  }
}
