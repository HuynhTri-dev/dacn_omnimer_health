// lib/presentation/screen/exercise/exercise_home/widgets/exercise_list_skeleton.dart
part of '../exercise_home_screen.dart';

class _ExerciseListSkeleton extends StatelessWidget {
  const _ExerciseListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.md.w),
      itemCount: 6,
      separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md.h),
      itemBuilder: (context, index) => const _ExerciseCardSkeleton(),
    );
  }
}

class _ExerciseCardSkeleton extends StatelessWidget {
  const _ExerciseCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail skeleton on the left
            Container(
              width: 85.w,
              height: 85.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.radiusMd,
              ),
            ),
            SizedBox(width: 12.w),

            // Content skeleton on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    width: double.infinity,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm.r),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Muscle names skeleton
                  Container(
                    width: 150.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm.r),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Equipment and Location row skeleton
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 60.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              width: 80.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 50.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Container(
                              width: 70.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
