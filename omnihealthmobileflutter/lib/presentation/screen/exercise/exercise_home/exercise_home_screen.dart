import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';

/// Trang Exercise - Hiển thị danh sách bài tập
/// TODO: Implement danh sách exercises, filter, search, etc.
class ExerciseHomeScreen extends StatelessWidget {
  const ExerciseHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // User Header
          const UserHeaderWidget(),

          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 80.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Đây là trang Exercise',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Danh sách bài tập sẽ được hiển thị ở đây',
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
