import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

/// Beautiful footer widget for register screen
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
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login_outlined,
            size: 18.sp,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            'Already have an account?',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.fontSizeXs.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          TextButton(
            onPressed: disabled ? null : onLoginTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Login Now!',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.fontSizeXs.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
