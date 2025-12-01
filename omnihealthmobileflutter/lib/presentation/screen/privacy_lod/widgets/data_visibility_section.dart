import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/bloc/privacy_lod_state.dart';

/// Data visibility section widget with toggle switches for each data type
class DataVisibilitySection extends StatelessWidget {
  final DataVisibilitySettings settings;
  final Function(String dataType, bool value) onToggle;

  const DataVisibilitySection({
    Key? key,
    required this.settings,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleItem(
          context,
          icon: Icons.directions_walk,
          iconColor: Colors.blue,
          title: 'Steps',
          subtitle: 'Daily step count data',
          value: settings.stepsVisible,
          onChanged: (value) => onToggle('steps', value),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildToggleItem(
          context,
          icon: Icons.favorite,
          iconColor: Colors.red,
          title: 'Heart Rate',
          subtitle: 'Heart rate measurements',
          value: settings.heartRateVisible,
          onChanged: (value) => onToggle('heartRate', value),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildToggleItem(
          context,
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          title: 'Calories',
          subtitle: 'Calories burned data',
          value: settings.caloriesVisible,
          onChanged: (value) => onToggle('calories', value),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildToggleItem(
          context,
          icon: Icons.bedtime,
          iconColor: Colors.purple,
          title: 'Sleep',
          subtitle: 'Sleep duration and quality',
          value: settings.sleepVisible,
          onChanged: (value) => onToggle('sleep', value),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildToggleItem(
          context,
          icon: Icons.fitness_center,
          iconColor: Colors.green,
          title: 'Workouts',
          subtitle: 'Exercise and training data',
          value: settings.workoutsVisible,
          onChanged: (value) => onToggle('workouts', value),
        ),
        SizedBox(height: AppSpacing.xs),
        _buildToggleItem(
          context,
          icon: Icons.monitor_weight,
          iconColor: Colors.teal,
          title: 'Weight',
          subtitle: 'Body weight measurements',
          value: settings.weightVisible,
          onChanged: (value) => onToggle('weight', value),
        ),
      ],
    );
  }

  Widget _buildToggleItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

