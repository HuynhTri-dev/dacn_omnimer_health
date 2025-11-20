import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

/// Trang Workout - Hiển thị danh sách workout plans
/// TODO: Implement danh sách workouts, lịch tập, tracking, etc.
class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Workout',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_gymnastics,
              size: 80.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Đây là trang Workout',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Kế hoạch tập luyện sẽ được hiển thị ở đây',
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
