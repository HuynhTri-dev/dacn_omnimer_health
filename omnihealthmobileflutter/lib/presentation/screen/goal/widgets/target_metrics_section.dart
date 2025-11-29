import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/section_title.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/target_metric_item.dart';

class TargetMetricsSection extends StatelessWidget {
  final List<TargetMetricEntity> metrics;
  final VoidCallback onAddMetric;
  final Function(int index, {String? name, double? value, String? unit})
  onUpdateMetric;
  final Function(int index) onRemoveMetric;

  const TargetMetricsSection({
    super.key,
    required this.metrics,
    required this.onAddMetric,
    required this.onUpdateMetric,
    required this.onRemoveMetric,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionTitle(title: 'Target Metrics'),
            IconButton(
              onPressed: onAddMetric,
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm.h),
        ...metrics.asMap().entries.map((entry) {
          final index = entry.key;
          final metric = entry.value;
          return TargetMetricItem(
            index: index,
            metric: metric,
            onUpdate: onUpdateMetric,
            onRemove: () => onRemoveMetric(index),
          );
        }).toList(),
      ],
    );
  }
}
