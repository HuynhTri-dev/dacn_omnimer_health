import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';

/// Widget cho phần Body Measurements
class BodyMeasurementsSection extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController waistController;
  final TextEditingController neckController;
  final TextEditingController hipController;

  const BodyMeasurementsSection({
    super.key,
    required this.heightController,
    required this.weightController,
    required this.waistController,
    required this.neckController,
    required this.hipController,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Body Measurements',
      icon: Icons.straighten,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Height (cm)',
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: CustomTextField(
                  label: 'Weight (kg)',
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  required: true,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Waist (cm)',
                  controller: waistController,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: CustomTextField(
                  label: 'Neck (cm)',
                  controller: neckController,
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: CustomTextField(
                  label: 'Hip (cm)',
                  controller: hipController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reusable Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
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
                child: Icon(icon, color: colorScheme.primary, size: 20.sp),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                title,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          child,
        ],
      ),
    );
  }
}
