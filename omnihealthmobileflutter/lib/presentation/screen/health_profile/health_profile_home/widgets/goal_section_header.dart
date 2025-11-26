import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

class GoalSectionHeader extends StatelessWidget {
  final VoidCallback onAddTap;

  const GoalSectionHeader({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'My Goal',
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: AppSpacing.md.w),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Icon(Icons.add, color: AppColors.textLight, size: 16.sp),
          ),
        ),
      ],
    );
  }
}
