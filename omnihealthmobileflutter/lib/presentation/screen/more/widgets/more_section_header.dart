import 'package:flutter/material.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';

/// Widget cho section header trong More screen
class MoreSectionHeader extends StatelessWidget {
  final String title;

  const MoreSectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.sm,
        top: AppSpacing.lg,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
