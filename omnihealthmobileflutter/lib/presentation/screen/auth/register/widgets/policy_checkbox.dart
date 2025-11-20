import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

/// Widget checkbox xác nhận chính sách bảo mật và điều khoản dịch vụ
/// Khi nhấn vào text sẽ mở PDF tương ứng
class PolicyCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onTermsOfServiceTap;
  final String? errorMessage;
  final bool disabled;

  const PolicyCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
    required this.onPrivacyPolicyTap,
    required this.onTermsOfServiceTap,
    this.errorMessage,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: isChecked,
                onChanged: disabled
                    ? null
                    : (value) => onChanged(value ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                side: BorderSide(
                  color: errorMessage != null
                      ? AppColors.error
                      : AppColors.border,
                  width: 1.5,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm.w),

            // Text với links
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyRegularStyle(
                    fontSize: AppTypography.fontSizeSm.sp,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Tôi đồng ý với '),
                    TextSpan(
                      text: 'Chính sách bảo mật',
                      style: AppTypography.bodyBoldStyle(
                        fontSize: AppTypography.fontSizeSm.sp,
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = disabled ? null : onPrivacyPolicyTap,
                    ),
                    const TextSpan(text: ' và '),
                    TextSpan(
                      text: 'Điều khoản dịch vụ',
                      style: AppTypography.bodyBoldStyle(
                        fontSize: AppTypography.fontSizeSm.sp,
                        color: AppColors.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = disabled ? null : onTermsOfServiceTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Error message
        if (errorMessage != null) ...[
          SizedBox(height: AppSpacing.xs.h),
          Padding(
            padding: EdgeInsets.only(left: (24 + AppSpacing.sm).w),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: AppColors.error,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeXs.sp,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
