import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';

/// Step 4: Success - Password reset complete
class SuccessStep extends StatelessWidget {
  /// If true, user came from authenticated screen (e.g., Change Password)
  final bool fromAuthenticated;

  const SuccessStep({
    Key? key,
    this.fromAuthenticated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: AppSpacing.xl.h * 2),

          // Success Icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade400,
                        Colors.green.shade600,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    size: 60.sp,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: AppSpacing.xl.h),

          // Title
          Text(
            'Đặt lại mật khẩu\nthành công!',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Text(
              fromAuthenticated
                  ? 'Mật khẩu của bạn đã được cập nhật thành công.'
                  : 'Mật khẩu của bạn đã được cập nhật thành công. Bạn có thể đăng nhập bằng mật khẩu mới.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.xl.h * 2),

          // Button - different based on context
          ButtonPrimary(
            title: fromAuthenticated ? 'Hoàn tất' : 'Quay lại đăng nhập',
            variant: ButtonVariant.primarySolid,
            size: ButtonSize.large,
            fullWidth: true,
            onPressed: () {
              if (fromAuthenticated) {
                // Pop back to previous screen (Change Password or More screen)
                Navigator.of(context).pop();
              } else {
                // Pop all routes and go to login
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),

          SizedBox(height: AppSpacing.lg.h),

          // Security tip
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.security,
                  color: Colors.blue,
                  size: 24.sp,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Lưu ý: Không chia sẻ mật khẩu với bất kỳ ai để bảo vệ tài khoản của bạn.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

