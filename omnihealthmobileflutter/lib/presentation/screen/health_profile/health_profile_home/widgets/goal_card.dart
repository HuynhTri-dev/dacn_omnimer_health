import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback onViewDetail;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onViewDetail,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateRange =
        '${dateFormat.format(goal.startDate)} - ${dateFormat.format(goal.endDate)}';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.goalType.displayName,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(dateRange, style: textTheme.bodyMedium),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: textTheme.bodySmall?.color,
              size: 24.sp,
            ),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            onSelected: (value) {
              switch (value) {
                case 'detail':
                  onViewDetail();
                  break;
                case 'update':
                  onUpdate();
                  break;
                case 'delete':
                  onDelete();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'detail',
                child: Row(
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 20.sp,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text('View Detail', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20.sp, color: Colors.orange),
                    SizedBox(width: 8.w),
                    Text('Update', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20.sp, color: colorScheme.error),
                    SizedBox(width: 8.w),
                    Text('Delete', style: textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
