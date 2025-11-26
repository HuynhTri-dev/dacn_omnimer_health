import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dateRange =
        '${dateFormat.format(goal.startDate)} - ${dateFormat.format(goal.endDate)}';

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
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
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  dateRange,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
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
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text('View Detail', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20.sp, color: AppColors.warning),
                    SizedBox(width: 8.w),
                    Text('Update', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20.sp, color: AppColors.error),
                    SizedBox(width: 8.w),
                    Text('Delete', style: AppTypography.bodyMedium),
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
