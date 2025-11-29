import 'package:flutter/material.dart';

class HealthMetricCard extends StatelessWidget {
  final String label;
  final String? value;
  final String? unit;

  const HealthMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(label, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value ?? '-',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (unit != null && value != null) ...[
              const SizedBox(width: 2),
              Text(
                unit!,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
