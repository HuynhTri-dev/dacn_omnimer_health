import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
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
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Metrics',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: calculateAutomatically,
                  onChanged: (value) =>
                      onCalculateAutomaticallyChanged(value ?? false),
                  activeColor: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'Calculate automatically from measurements',
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeSm.sp,
                      color: AppColors.textPrimary,
                    ),
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
                ? _buildAutoCalculateMessage()
                : _buildManualInputFields(),
          ),
        ],
      ),
    );
  }

  /// Message shown when auto-calculate is enabled
  Widget _buildAutoCalculateMessage() {
    return Container(
      key: const ValueKey('auto_message'),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: 24.sp),
          SizedBox(width: AppSpacing.sm.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-calculation enabled',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Metrics will be automatically calculated from your body measurements',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
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
