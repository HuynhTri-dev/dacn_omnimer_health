import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

/// Widget footer with text "Already have an account? Login"
/// Tapping "Login" will navigate back to login page
class RegisterFooter extends StatelessWidget {
  final VoidCallback onLoginTap;
  final bool disabled;

  const RegisterFooter({
    Key? key,
    required this.onLoginTap,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md.h),
      child: Center(
        child: RichText(
          text: TextSpan(
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeBase.sp,
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Login',
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.primary,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = disabled ? null : onLoginTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
