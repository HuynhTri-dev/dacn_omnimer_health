import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
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
      builder: (context, scrollController) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
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
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Builder(
      builder: (context) => Center(
        child: Container(
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(AppRadius.sm.r),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Builder(
      builder: (context) => Text(
        goal.goalType.displayName,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateRange() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Builder(
      builder: (context) => Text(
        '${dateFormat.format(goal.startDate)} - ${dateFormat.format(goal.endDate)}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFrequencySection() {
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequency',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Text(
              '${goal.repeat!.frequency.toUpperCase()} ${goal.repeat!.interval != null ? '(Every ${goal.repeat!.interval})' : ''}',
              style: textTheme.bodyMedium,
            ),
            if (goal.repeat!.daysOfWeek != null &&
                goal.repeat!.daysOfWeek!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs.h),
                child: Text(
                  'Days: ${goal.repeat!.daysOfWeek!.join(', ')}',
                  style: textTheme.bodySmall,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMetricsSection() {
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Metrics',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.md.h),
            ...goal.targetMetric.map((metric) => _buildMetricItem(metric)),
          ],
        );
      },
    );
  }

  Widget _buildMetricItem(TargetMetricEntity metric) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md.h),
          padding: EdgeInsets.all(AppSpacing.md.w),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: AppRadius.radiusMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                metric.metricName,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${metric.value} ${metric.unit ?? ''}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                  side: BorderSide(color: colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Delete',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
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
      },
    );
  }
}
