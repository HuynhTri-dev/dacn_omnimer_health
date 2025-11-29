import 'package:flutter/material.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:intl/intl.dart';

class AdvanceTabView extends StatelessWidget {
  final HealthProfile profile;

  const AdvanceTabView({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Evaluation Section
          if (profile.aiEvaluation != null) ...[
            const Text(
              'AI Health Evaluation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAiEvaluationCard(),
            const SizedBox(height: 24),
          ] else ...[
            const Text(
              'AI Health Evaluation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                final textTheme = theme.textTheme;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'AI is analyzing your health data. Please come back later.',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Health Status Section
          const Text(
            'Health Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            if (profile.restingHeartRate != null)
              _buildInfoRow(
                'Resting Heart Rate',
                '${profile.restingHeartRate} bpm',
              ),
            if (profile.bloodPressure != null)
              _buildInfoRow(
                'Blood Pressure',
                '${profile.bloodPressure!.systolic}/${profile.bloodPressure!.diastolic} mmHg',
              ),
            if (profile.cholesterol != null) ...[
              _buildInfoRow(
                'Total Cholesterol',
                '${profile.cholesterol!.total} mg/dL',
              ),
              _buildInfoRow('HDL', '${profile.cholesterol!.hdl} mg/dL'),
              _buildInfoRow('LDL', '${profile.cholesterol!.ldl} mg/dL'),
            ],
            if (profile.bloodSugar != null)
              _buildInfoRow('Blood Sugar', '${profile.bloodSugar} mg/dL'),
            if (profile.healthStatus != null) ...[
              if (profile.healthStatus!.knownConditions.isNotEmpty)
                _buildInfoRow(
                  'Known Conditions',
                  profile.healthStatus!.knownConditions.join(', '),
                ),
              if (profile.healthStatus!.painLocations.isNotEmpty)
                _buildInfoRow(
                  'Pain Locations',
                  profile.healthStatus!.painLocations.join(', '),
                ),
              if (profile.healthStatus!.jointIssues.isNotEmpty)
                _buildInfoRow(
                  'Joint Issues',
                  profile.healthStatus!.jointIssues.join(', '),
                ),
              if (profile.healthStatus!.injuries.isNotEmpty)
                _buildInfoRow(
                  'Injuries',
                  profile.healthStatus!.injuries.join(', '),
                ),
              if (profile.healthStatus!.abnormalities.isNotEmpty)
                _buildInfoRow(
                  'Abnormalities',
                  profile.healthStatus!.abnormalities.join(', '),
                ),
              if (profile.healthStatus!.notes != null &&
                  profile.healthStatus!.notes!.isNotEmpty)
                _buildInfoRow('Notes', profile.healthStatus!.notes!),
            ],
          ]),
        ],
      ),
    );
  }

  Widget _buildAiEvaluationCard() {
    final aiEval = profile.aiEvaluation!;
    final riskColor = _getRiskColor(aiEval.riskLevel);
    final riskLabel = _getRiskLabel(aiEval.riskLevel);

    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.surface,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Score and Risk Level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Score Badge
                  if (aiEval.score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(aiEval.score!),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${aiEval.score}/100',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Risk Level Badge
                  if (aiEval.riskLevel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: riskColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRiskIcon(aiEval.riskLevel),
                            color: riskColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            riskLabel,
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // AI Summary
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        aiEval.summary,
                        style: textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              // Metadata
              if (aiEval.updatedAt != null || aiEval.modelVersion != null) ...[
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (aiEval.updatedAt != null)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Updated ${DateFormat('MMM dd, yyyy').format(aiEval.updatedAt!)}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    if (aiEval.modelVersion != null) ...[
                      if (aiEval.updatedAt != null) const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.memory,
                            size: 14,
                            color: textTheme.bodySmall?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'v${aiEval.modelVersion}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getRiskColor(RiskLevelEnum? riskLevel) {
    switch (riskLevel) {
      case RiskLevelEnum.Low:
        return Colors.green;
      case RiskLevelEnum.Medium:
        return Colors.orange;
      case RiskLevelEnum.High:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRiskLabel(RiskLevelEnum? riskLevel) {
    switch (riskLevel) {
      case RiskLevelEnum.Low:
        return 'Low Risk';
      case RiskLevelEnum.Medium:
        return 'Medium Risk';
      case RiskLevelEnum.High:
        return 'High Risk';
      default:
        return 'Unknown';
    }
  }

  IconData _getRiskIcon(RiskLevelEnum? riskLevel) {
    switch (riskLevel) {
      case RiskLevelEnum.Low:
        return Icons.check_circle;
      case RiskLevelEnum.Medium:
        return Icons.warning;
      case RiskLevelEnum.High:
        return Icons.error;
      default:
        return Icons.help;
    }
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
              Flexible(
                child: Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
