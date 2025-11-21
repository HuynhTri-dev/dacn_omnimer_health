import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_detail_entity.dart';

import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/detail_row.dart';

class ExerciseDetailBody extends StatelessWidget {
  final ExerciseDetailEntity exercise;
  final List<String> muscleNames;

  const ExerciseDetailBody({
    Key? key,
    required this.exercise,
    required this.muscleNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusAreaText = muscleNames.isEmpty ? '-' : muscleNames.join(', ');
    final equipmentText = exercise.equipments.isEmpty
        ? '-'
        : exercise.equipments.map((e) => e.name).join(', ');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery or video placeholder
          if (exercise.imageUrls.isNotEmpty)
            SizedBox(
              height: 200.h,
              child: PageView.builder(
                itemCount: exercise.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
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
                    child: ClipRRect(
                      borderRadius: AppRadius.radiusXl,
                      child: Image.network(
                        exercise.imageUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48.sp,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            )
          else
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
                'No Image',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          SizedBox(height: 24.h),

          // Exercise details
          DetailRow(label: 'Focus Area:', value: focusAreaText),
          SizedBox(height: 8.h),

          DetailRow(label: 'Equipment:', value: equipmentText),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Difficulty:',
            value: exercise.difficulty.isEmpty ? '-' : exercise.difficulty,
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Location:',
            value: exercise.location.isEmpty ? '-' : exercise.location,
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'MET:',
            value: exercise.met == null ? '-' : exercise.met.toString(),
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Average Score:',
            value: exercise.averageScore == null
                ? 'Not rated yet'
                : '${exercise.averageScore!.toStringAsFixed(1)} / 5.0',
          ),
          SizedBox(height: 16.h),

          // Description
          if (exercise.description.isNotEmpty) ...[
            Text('Description', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Text(exercise.description, style: AppTypography.bodyMedium),
            SizedBox(height: 16.h),
          ],

          // Instructions
          if (exercise.instructions.isNotEmpty) ...[
            Text('Instructions', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Text(exercise.instructions, style: AppTypography.bodyMedium),
            SizedBox(height: 16.h),
          ],

          // Exercise Types
          if (exercise.exerciseTypes.isNotEmpty) ...[
            Text('Exercise Types', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: exercise.exerciseTypes.map((type) {
                return Chip(
                  label: Text(type.name),
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          // Exercise Categories
          if (exercise.exerciseCategories.isNotEmpty) ...[
            Text('Categories', style: AppTypography.h3),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: exercise.exerciseCategories.map((category) {
                return Chip(
                  label: Text(category.name),
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  labelStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.secondary,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
