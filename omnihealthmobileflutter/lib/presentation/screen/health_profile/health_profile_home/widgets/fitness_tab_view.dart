import 'package:flutter/material.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';

class FitnessTabView extends StatelessWidget {
  final HealthProfile profile;

  const FitnessTabView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitness Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            if (profile.maxPushUps != null)
              _buildInfoRow('Max Push Ups', '${profile.maxPushUps}'),
            if (profile.maxWeightLifted != null)
              _buildInfoRow(
                'Max Weight Lifted',
                '${profile.maxWeightLifted} kg',
              ),
            if (profile.activityLevel != null)
              _buildInfoRow('Activity Level', '${profile.activityLevel}/5'),
            if (profile.experienceLevel != null)
              _buildInfoRow(
                'Experience Level',
                profile.experienceLevel?.displayName ?? '-',
              ),
            if (profile.workoutFrequency != null)
              _buildInfoRow(
                'Workout Frequency',
                '${profile.workoutFrequency} days/week',
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Builder(
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.bodyMedium),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
