import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title
          Text(
            profile != null ? 'Health Profile' : 'Create Profile',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          GestureDetector(
            onTap: onDateTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Checkup Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (profile == null && onCreateTap != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onCreateTap,
                        child: const Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
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
