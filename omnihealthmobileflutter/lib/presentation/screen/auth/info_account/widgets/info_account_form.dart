import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';

class InfoAccountForm extends StatelessWidget {
  final TextEditingController fullnameController;
  final TextEditingController birthdayController;
  final GenderEnum? selectedGender;
  final ValueChanged<GenderEnum?> onGenderChanged;
  final VoidCallback onSelectDate;
  final bool isLoading;

  const InfoAccountForm({
    super.key,
    required this.fullnameController,
    required this.birthdayController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onSelectDate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: fullnameController,
          label: "Fullname",
          placeholder: "Enter fullname",
          enabled: !isLoading,
          leftIcon: Icon(
            Icons.person_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        GestureDetector(
          onTap: isLoading ? null : onSelectDate,
          child: AbsorbPointer(
            child: CustomTextField(
              controller: birthdayController,
              label: "Birthday",
              placeholder: "YYYY-MM-DD",
              enabled: !isLoading,
              leftIcon: Icon(
                Icons.cake_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              rightIcon: Icon(
                Icons.calendar_today,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        _buildGenderDropdown(),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gender",
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: Border.all(color: theme.dividerColor, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<GenderEnum>(
                  value: selectedGender,
                  isExpanded: true,
                  hint: const Text("Choose gender"),
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                  items: GenderEnum.values.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Row(
                        children: [
                          Icon(
                            gender == GenderEnum.male
                                ? Icons.male
                                : gender == GenderEnum.female
                                ? Icons.female
                                : Icons.transgender,
                            size: 20.w,
                            color: textTheme.bodySmall?.color,
                          ),
                          SizedBox(width: 8.w),
                          Text(gender.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: isLoading ? null : onGenderChanged,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
