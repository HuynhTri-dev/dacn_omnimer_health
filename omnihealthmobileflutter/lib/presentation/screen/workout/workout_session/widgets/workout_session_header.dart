part of '../workout_session_screen.dart';

class _WorkoutSessionHeader extends StatelessWidget {
  final String workoutName;
  final String formattedTime;
  final VoidCallback onBack;
  final VoidCallback onFinish;
  final VoidCallback onEditTime;
  final VoidCallback onEditName;

  const _WorkoutSessionHeader({
    required this.workoutName,
    required this.formattedTime,
    required this.onBack,
    required this.onFinish,
    required this.onEditTime,
    required this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBack,
            icon: Icon(
              Icons.chevron_left,
              size: 28.sp,
              color: AppColors.textPrimary,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 40.w,
              minHeight: 40.h,
            ),
          ),

          // Workout name and timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Workout name with edit button
                GestureDetector(
                  onTap: onEditName,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          workoutName,
                          style: AppTypography.bodyBoldStyle(
                            fontSize: AppTypography.fontSizeSm,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                // Timer with edit button
                GestureDetector(
                  onTap: onEditTime,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTime,
                        style: AppTypography.headingBoldStyle(
                          fontSize: AppTypography.fontSizeXl,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        Icons.edit,
                        size: 14.sp,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Finish button
          ElevatedButton(
            onPressed: onFinish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg.w,
                vertical: AppSpacing.sm.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusSm,
              ),
              elevation: 0,
            ),
            child: Text(
              'FINISH',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

