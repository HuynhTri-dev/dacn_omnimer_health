import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';

class GoalSectionHeader extends StatelessWidget {
  final VoidCallback onAddTap;

  const GoalSectionHeader({super.key, required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Text(
          'My Goal',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: AppSpacing.md.w),
        GestureDetector(
          onTap: onAddTap,
          child: Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Icon(Icons.add, color: colorScheme.onPrimary, size: 16.sp),
          ),
        ),
      ],
    );
  }
}
