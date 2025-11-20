import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

/// Trang Health Profile - Hiển thị thông tin sức khỏe người dùng
/// TODO: Implement health metrics, stats, charts, health data từ devices, etc.
class HealthProfileHomeScreen extends StatelessWidget {
  const HealthProfileHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Health Profile',
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
            Icon(Icons.favorite, size: 80.sp, color: AppColors.primary),
            SizedBox(height: 16.h),
            Text(
              'Đây là trang Health Profile',
              style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Thông tin sức khỏe sẽ được hiển thị ở đây',
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
