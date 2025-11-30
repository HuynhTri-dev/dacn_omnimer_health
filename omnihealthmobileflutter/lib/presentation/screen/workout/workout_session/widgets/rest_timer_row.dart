part of '../workout_session_screen.dart';

class _RestTimerRow extends StatelessWidget {
  final int exerciseIndex;
  final int setIndex;

  const _RestTimerRow({required this.exerciseIndex, required this.setIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
      buildWhen: (previous, current) =>
          previous.isResting != current.isResting ||
          previous.restTimeRemaining != current.restTimeRemaining ||
          previous.restExerciseIndex != current.restExerciseIndex ||
          previous.restSetIndex != current.restSetIndex,
      builder: (context, state) {
        // Only show if this set is currently resting
        if (!state.isSetResting(exerciseIndex, setIndex)) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.xs.h,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Rest icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(Icons.timer, size: 20.sp, color: AppColors.white),
              ),
              SizedBox(width: AppSpacing.md.w),

              // Rest timer text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nghỉ ngơi',
                      style: AppTypography.bodyRegularStyle(
                        fontSize: AppTypography.fontSizeXs,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      state.formattedRestTime,
                      style: AppTypography.headingBoldStyle(
                        fontSize: AppTypography.fontSizeXl,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Add time button
              IconButton(
                onPressed: () {
                  context.read<WorkoutSessionBloc>().add(AddRestTimeEvent(30));
                },
                icon: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '+30s',
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeXs,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 48.w, minHeight: 36.h),
              ),

              // Skip button
              TextButton(
                onPressed: () {
                  context.read<WorkoutSessionBloc>().add(SkipRestTimerEvent());
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md.w,
                    vertical: AppSpacing.sm.h,
                  ),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Bỏ qua',
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeSm,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
