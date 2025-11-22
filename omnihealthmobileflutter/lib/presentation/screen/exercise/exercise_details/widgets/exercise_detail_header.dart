import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

class ExerciseDetailHeader extends StatelessWidget {
  final String exerciseName;
  final double currentRating;
  final VoidCallback onBack;

  const ExerciseDetailHeader({
    Key? key,
    required this.exerciseName,
    required this.currentRating,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showDash = currentRating <= 0;
    final ratingText = showDash ? '-' : currentRating.toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exerciseName,
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
                Text('Rating: $ratingText | 5', style: AppTypography.caption),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}
