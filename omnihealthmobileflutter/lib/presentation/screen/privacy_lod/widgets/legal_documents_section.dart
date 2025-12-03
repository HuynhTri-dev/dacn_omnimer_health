import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';

/// Legal documents section widget displaying Privacy Policy and Terms links
class LegalDocumentsSection extends StatelessWidget {
  final VoidCallback onPrivacyPolicyTap;
  final bool isPrivacyAccepted;

  const LegalDocumentsSection({
    Key? key,
    required this.onPrivacyPolicyTap,
    this.isPrivacyAccepted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Privacy Policy
        _buildDocumentItem(
          context,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy Policy',
          subtitle: 'How we collect and use your data',
          isAccepted: isPrivacyAccepted,
          onTap: onPrivacyPolicyTap,
        ),
      ],
    );
  }

  Widget _buildDocumentItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isAccepted,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24.sp),
            ),
            SizedBox(width: AppSpacing.md),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Status indicator
            if (isAccepted)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      'Agreed',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurface.withOpacity(0.4),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
