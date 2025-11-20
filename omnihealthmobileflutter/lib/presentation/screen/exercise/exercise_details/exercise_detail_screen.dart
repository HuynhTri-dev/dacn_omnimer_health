import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/cubits/exercise_cubit.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final ExerciseModel exercise;
  final List<String> muscleNames;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
    required this.muscleNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusAreaText = muscleNames.isEmpty ? '-' : muscleNames.join(', ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ===== HEADER =====
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Tên bài tập + chấm xanh
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.h2,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Container(
                              width: 10.w,
                              height: 10.w,
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          // nếu chưa có rating thì hiển thị “Rating: - | 5”
                          'Rating: ${exercise.rating?.toStringAsFixed(1) ?? '-'} | 5',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ===== BODY =====
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Khung video
                    Container(
                      height: 200.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.radiusXl,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Video',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    _DetailRow(label: 'Focus Area:', value: focusAreaText),
                    SizedBox(height: 8.h),

                    _DetailRow(
                      label: 'Equipment:',
                      value: exercise.equipment.isEmpty
                          ? '-'
                          : exercise.equipment,
                    ),
                    SizedBox(height: 8.h),

                    // Tạm thời dùng type làm Met cho đúng layout
                    _DetailRow(
                      label: 'Met:',
                      value: exercise.met == null
                          ? '-'
                          : exercise.met.toString(),
                    ),
                    SizedBox(height: 8.h),

                    _DetailRow(
                      label: 'Description:',
                      value: exercise.description.isEmpty
                          ? '-'
                          : exercise.description,
                    ),
                    SizedBox(height: 8.h),

                    _DetailRow(
                      label: 'Instructions:',
                      value: exercise.instructions.isEmpty
                          ? '-'
                          : exercise.instructions,
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ===== BUTTON RATING DƯỚI GÓC PHẢI =====
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: 16.w, bottom: 8.h),
        child: Material(
          elevation: 6, // làm nút nổi lên
          borderRadius: AppRadius.radiusLg,
          color: Colors.transparent,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              backgroundColor: Colors.white,
            ),
            onPressed: () => _showRatingSheet(context),
            child: Text(
              'Rating',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Hiện bottom sheet rating như mockup
  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        double currentRating = exercise.rating ?? 0;
        bool isLoading = false;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            0,
            16.w,
            16.h + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
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
                      exercise.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption,
                    ),
                    SizedBox(height: 16.h),

                    // Hàng 5 ngôi sao
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final filled = starIndex <= currentRating.round();
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(
                              () => currentRating = starIndex.toDouble(),
                            );
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

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Nút đóng (icon vuông)
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

                        // Nút xác nhận -> GỌI API
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
                                    setState(() => isLoading = true);
                                    final cubit = context.read<ExerciseCubit>();

                                    try {
                                      await cubit.submitRating(
                                        exercise,
                                        currentRating,
                                      );

                                      if (context.mounted) {
                                        Navigator.of(ctx).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Đã gửi đánh giá'),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
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
                                        setState(() => isLoading = false);
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
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const TextSpan(text: ' '),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
