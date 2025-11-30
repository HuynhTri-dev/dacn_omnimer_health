part of '../workout_session_screen.dart';

class _ActiveExerciseCard extends StatelessWidget {
  final ActiveExerciseEntity exercise;
  final int exerciseIndex;

  const _ActiveExerciseCard({
    required this.exercise,
    required this.exerciseIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutSessionBloc, WorkoutSessionState>(
      buildWhen: (previous, current) =>
          previous.currentExerciseIndex != current.currentExerciseIndex ||
          previous.currentSetIndex != current.currentSetIndex ||
          previous.isResting != current.isResting ||
          previous.restExerciseIndex != current.restExerciseIndex ||
          previous.restSetIndex != current.restSetIndex,
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.radiusMd,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Exercise header
              _buildExerciseHeader(context),

              // Sets list (when expanded)
              if (exercise.isExpanded) ...[
                // Sets with rest timer
                ...exercise.sets.asMap().entries.expand((entry) {
                  final isCurrentSet = state.isCurrentSet(
                    exerciseIndex,
                    entry.key,
                  );
                  return [
                    _ActiveSetRow(
                      set: entry.value,
                      exerciseIndex: exerciseIndex,
                      setIndex: entry.key,
                      isCurrentSet: isCurrentSet,
                    ),
                    // Rest timer row (shows only when this set is resting)
                    _RestTimerRow(
                      exerciseIndex: exerciseIndex,
                      setIndex: entry.key,
                    ),
                  ];
                }),

                // Add set button
                _buildAddSetButton(context),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseHeader(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<WorkoutSessionBloc>().add(
          ToggleExerciseExpansionEvent(exerciseIndex),
        );
      },
      borderRadius: AppRadius.topMd,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md.w),
        child: Row(
          children: [
            // Expand/collapse icon
            Icon(
              exercise.isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              size: 24.sp,
              color: AppColors.textMuted,
            ),
            SizedBox(width: AppSpacing.sm.w),

            // Exercise image
            ClipRRect(
              borderRadius: AppRadius.radiusSm,
              child:
                  exercise.exerciseImageUrl != null &&
                      exercise.exerciseImageUrl!.isNotEmpty
                  ? Image.network(
                      exercise.exerciseImageUrl!,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholderImage();
                      },
                    )
                  : _buildPlaceholderImage(),
            ),
            SizedBox(width: AppSpacing.md.w),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeBase,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        exercise.isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 16.sp,
                        color: exercise.isCompleted
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${exercise.completedSetsCount}/${exercise.totalSetsCount} Done',
                        style: AppTypography.bodyRegularStyle(
                          fontSize: AppTypography.fontSizeXs,
                          color: exercise.isCompleted
                              ? AppColors.success
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More options
            IconButton(
              onPressed: () => _showExerciseOptions(context),
              icon: Icon(
                Icons.more_vert,
                size: 20.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Icon(
        Icons.fitness_center,
        size: 24.sp,
        color: AppColors.textMuted,
      ),
    );
  }

  Widget _buildAddSetButton(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<WorkoutSessionBloc>().add(AddSetEvent(exerciseIndex));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18.sp, color: AppColors.textSecondary),
            SizedBox(width: 4.w),
            Text(
              'Add a set',
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.topLg),
      builder: (context) => Container(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: AppRadius.radiusSm,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.primary),
              title: Text(
                'Xem chi tiết bài tập',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  RouteConfig.exerciseDetail,
                  arguments: {'exerciseId': exercise.exerciseId},
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.swap_vert, color: AppColors.secondary),
              title: Text(
                'Thay đổi thứ tự',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.danger),
              title: Text(
                'Xóa bài tập',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase,
                  color: AppColors.danger,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
        ),
      ),
    );
  }
}
