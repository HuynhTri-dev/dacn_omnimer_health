import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:url_launcher/url_launcher.dart';

/// Beautiful checkbox widget for privacy policy and terms of service
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

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: disabled ? null : () => onChanged(!isChecked),
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xs.h,
              horizontal: AppSpacing.xs.w,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom checkbox
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: errorMessage != null
                          ? theme.colorScheme.error
                          : isChecked
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: isChecked
                      ? Icon(
                          Icons.check,
                          size: 16.sp,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
                SizedBox(width: AppSpacing.sm.w),

                // Text with links
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: AppTypography.fontSizeXs.sp,
                        color: theme.textTheme.bodyMedium?.color,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: AppTypography.fontSizeXs.sp,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = disabled
                                ? null
                                : () => _launchUrl(
                                    'https://doc-hosting.flycricket.io/omnimer-health-privacy-policy/37b589ac-7f6f-4ee9-9b0f-fb1ffabc4f04/privacy',
                                  ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: AppTypography.fontSizeXs.sp,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = disabled
                                ? null
                                : () => _launchUrl(
                                    'https://doc-hosting.flycricket.io/omnimer-health-terms-of-use/ce114c8b-104b-4030-bc6f-a5242c146070/terms',
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Error message with icon
        if (errorMessage != null) ...[
          SizedBox(height: AppSpacing.xs.h),
          Padding(
            padding: EdgeInsets.only(
              left: (22.w + AppSpacing.sm.w + AppSpacing.xs.w),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 14.sp,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: AppTypography.fontSizeXs.sp,
                      color: theme.colorScheme.error,
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
