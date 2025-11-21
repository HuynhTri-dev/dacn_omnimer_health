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
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton
            Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg.r),
                  topRight: Radius.circular(AppRadius.lg.r),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppSpacing.md.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title skeleton
                  Container(
                    width: double.infinity,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(AppRadius.sm.r),
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),

                  // Subtitle skeleton
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: AppColors.gray200,
                      borderRadius: BorderRadius.circular(AppRadius.sm.r),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // Tags skeleton
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(AppRadius.sm.r),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Container(
                        width: 80.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(AppRadius.sm.r),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Container(
                        width: 70.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(AppRadius.sm.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // Rating skeleton
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Padding(
                          padding: EdgeInsets.only(right: 2.w),
                          child: Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: const BoxDecoration(
                              color: AppColors.gray200,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Container(
                        width: 40.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(AppRadius.sm.r),
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
