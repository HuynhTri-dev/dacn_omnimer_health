import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';

import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/detail_row.dart';

class ExerciseDetailBody extends StatelessWidget {
  final ExerciseModel exercise;
  final List<String> muscleNames;

  const ExerciseDetailBody({
    Key? key,
    required this.exercise,
    required this.muscleNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final focusAreaText = muscleNames.isEmpty ? '-' : muscleNames.join(', ');

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          DetailRow(label: 'Focus Area:', value: focusAreaText),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Equipment:',
            value: exercise.equipment.isEmpty ? '-' : exercise.equipment,
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Met:',
            value: exercise.met == null ? '-' : exercise.met.toString(),
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Description:',
            value: exercise.description.isEmpty ? '-' : exercise.description,
          ),
          SizedBox(height: 8.h),

          DetailRow(
            label: 'Instructions:',
            value: exercise.instructions.isEmpty ? '-' : exercise.instructions,
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }
}
