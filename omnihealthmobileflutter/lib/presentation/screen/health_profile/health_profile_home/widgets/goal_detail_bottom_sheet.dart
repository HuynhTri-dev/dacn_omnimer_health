import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';

class GoalDetailBottomSheet extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const GoalDetailBottomSheet({
    super.key,
    required this.goal,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadius.topLg,
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(AppSpacing.xl.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              SizedBox(height: AppSpacing.xl.h),
              _buildTitle(),
              SizedBox(height: AppSpacing.sm.h),
              _buildDateRange(),
              if (goal.repeat != null) ...[
                SizedBox(height: AppSpacing.xl.h),
                _buildFrequencySection(),
              ],
              SizedBox(height: AppSpacing.xl.h),
              _buildMetricsSection(),
              SizedBox(height: AppSpacing.xxl.h),
              _buildActionButtons(),
              SizedBox(height: AppSpacing.xl.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.gray300,
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      goal.goalType.displayName,
      style: AppTypography.headingBoldStyle(
        fontSize: AppTypography.fontSizeXl.sp,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildDateRange() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Text(
      '${dateFormat.format(goal.startDate)} - ${dateFormat.format(goal.endDate)}',
      style: AppTypography.bodyRegularStyle(
        fontSize: AppTypography.fontSizeBase.sp,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.sm.h),
        Text(
          '${goal.repeat!.frequency.toUpperCase()} ${goal.repeat!.interval != null ? '(Every ${goal.repeat!.interval})' : ''}',
          style: AppTypography.bodyRegularStyle(
            fontSize: AppTypography.fontSizeBase.sp,
            color: AppColors.textPrimary,
          ),
        ),
        if (goal.repeat!.daysOfWeek != null &&
            goal.repeat!.daysOfWeek!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs.h),
            child: Text(
              'Days: ${goal.repeat!.daysOfWeek!.join(', ')}',
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeSm.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMetricsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Metrics',
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppSpacing.md.h),
        ...goal.targetMetric.map((metric) => _buildMetricItem(metric)),
      ],
    );
  }

  Widget _buildMetricItem(TargetMetricEntity metric) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            metric.metricName,
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeBase.sp,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '${metric.value} ${metric.unit ?? ''}',
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeBase.sp,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            child: Text(
              'Delete',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.error,
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md.w),
        Expanded(
          child: ButtonPrimary(title: 'Update', onPressed: onUpdate),
        ),
      ],
    );
  }
}
