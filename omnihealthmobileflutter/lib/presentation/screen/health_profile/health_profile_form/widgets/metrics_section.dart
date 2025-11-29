import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';

/// Widget cho phần Metrics (BMI, BMR, WHR, Body Fat, Muscle Mass)
class MetricsSection extends StatelessWidget {
  final bool calculateAutomatically;
  final ValueChanged<bool> onCalculateAutomaticallyChanged;
  final TextEditingController bmiController;
  final TextEditingController bmrController;
  final TextEditingController whrController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;

  const MetricsSection({
    super.key,
    required this.calculateAutomatically,
    required this.onCalculateAutomaticallyChanged,
    required this.bmiController,
    required this.bmrController,
    required this.whrController,
    required this.bodyFatController,
    required this.muscleMassController,
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
                  Icons.analytics,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Metrics',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),

          // Auto-calculate checkbox
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: AppSpacing.xs.h,
            ),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: calculateAutomatically,
                  onChanged: (value) =>
                      onCalculateAutomaticallyChanged(value ?? false),
                ),
                Expanded(
                  child: Text(
                    'Calculate automatically from measurements',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md.h),

          // Animated content based on calculateAutomatically
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(sizeFactor: animation, child: child),
              );
            },
            child: calculateAutomatically
                ? _buildAutoCalculateMessage(context)
                : _buildManualInputFields(),
          ),
        ],
      ),
    );
  }

  /// Message shown when auto-calculate is enabled
  Widget _buildAutoCalculateMessage(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      key: const ValueKey('auto_message'),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: colorScheme.primary, size: 24.sp),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-calculation enabled',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Metrics will be automatically calculated from your body measurements',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Manual input fields for metrics
  Widget _buildManualInputFields() {
    return Column(
      key: const ValueKey('manual_fields'),
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'BMI',
                controller: bmiController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: CustomTextField(
                label: 'BMR',
                controller: bmrController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'WHR',
                controller: whrController,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: CustomTextField(
                label: 'Body Fat (%)',
                controller: bodyFatController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        CustomTextField(
          label: 'Muscle Mass',
          controller: muscleMassController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
