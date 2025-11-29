import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class HealthProfileHeaderWidget extends StatelessWidget {
  final HealthProfile? profile;
  final VoidCallback onDateTap;
  final String? imageUrl;
  final DateTime selectedDate;
  final VoidCallback? onCreateTap;

  const HealthProfileHeaderWidget({
    Key? key,
    required this.profile,
    required this.onDateTap,
    this.imageUrl,
    required this.selectedDate,
    this.onCreateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            profile != null ? 'Health Profile' : 'Create Profile',
            style: textTheme.headlineMedium,
          ),
          GestureDetector(
            onTap: onDateTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Checkup Date', style: textTheme.bodySmall),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (profile == null && onCreateTap != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onCreateTap,
                        child: Icon(
                          Icons.add_circle,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
