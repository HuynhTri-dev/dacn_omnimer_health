part of '../workout_session_screen.dart';

class _WorkoutSessionBottomBar extends StatelessWidget {
  final VoidCallback onLogNextSet;
  final VoidCallback onToggleAll;
  final bool allCompleted;

  const _WorkoutSessionBottomBar({
    required this.onLogNextSet,
    required this.onToggleAll,
    required this.allCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.md.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Toggle all checkbox
            GestureDetector(
              onTap: onToggleAll,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.sm.w),
                decoration: BoxDecoration(
                  color: allCompleted
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.gray100,
                  borderRadius: AppRadius.radiusSm,
                  border: Border.all(
                    color: allCompleted ? AppColors.success : AppColors.gray300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      allCompleted
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 20.sp,
                      color: allCompleted
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'ALL',
                      style: AppTypography.bodyBoldStyle(
                        fontSize: AppTypography.fontSizeXs,
                        color: allCompleted
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md.w),

            // Log next set button
            Expanded(
              child: ElevatedButton(
                onPressed: allCompleted ? null : onLogNextSet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.gray300,
                  disabledForegroundColor: AppColors.textMuted,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  allCompleted ? 'ALL COMPLETED' : 'LOG NEXT SET',
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeBase,
                    color: allCompleted ? AppColors.textMuted : AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

