import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';

Future<void> showExerciseRatingSheet({
  required BuildContext parentContext,
  required String exerciseId,
  required String exerciseName,
  required double currentRating,
}) async {
  await showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      double tempRating = currentRating <= 0 ? 0 : currentRating;
      bool isLoading = false;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16.w,
          0,
          16.w,
          16.h + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, modalSetState) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusXl,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 18,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How would you rate this exercise?',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    exerciseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  SizedBox(height: 16.h),

                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      final filled = starIndex <= tempRating.round();
                      return IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          modalSetState(() {
                            tempRating = starIndex.toDouble();
                          });
                        },
                        icon: Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 32.r,
                          color: filled
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 40.h,
                        width: 40.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMd,
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Icon(
                            Icons.exit_to_app_rounded,
                            size: 20,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 40.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusLg,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  modalSetState(() => isLoading = true);

                                  final cubit = parentContext
                                      .read<ExerciseDetailCubit>();

                                  try {
                                    final success = await cubit.submitRating(
                                      exerciseId: exerciseId,
                                      score: tempRating,
                                    );

                                    if (ctx.mounted) {
                                      Navigator.of(ctx).pop();
                                    }

                                    if (parentContext.mounted) {
                                      ScaffoldMessenger.of(
                                        parentContext,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success
                                                ? 'Đã gửi đánh giá'
                                                : 'Bạn đã đánh giá bài tập này rồi',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (parentContext.mounted) {
                                      ScaffoldMessenger.of(
                                        parentContext,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Gửi đánh giá thất bại',
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (ctx.mounted) {
                                      modalSetState(() => isLoading = false);
                                    }
                                  }
                                },
                          child: isLoading
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Confirm',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
