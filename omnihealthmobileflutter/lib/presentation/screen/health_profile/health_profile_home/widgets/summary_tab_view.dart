import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/health_metric_card.dart';

class SummaryTabView extends StatefulWidget {
  final HealthProfile profile;
  final String? imageUrl;

  const SummaryTabView({super.key, required this.profile, this.imageUrl});

  @override
  State<SummaryTabView> createState() => _SummaryTabViewState();
}

class _SummaryTabViewState extends State<SummaryTabView> {
  void _handleUpdate(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      RouteConfig.healthProfileForm,
      arguments: {'profileId': widget.profile.id},
    );

    if (result == true && mounted) {
      // Refresh profile after update
      context.read<HealthProfileBloc>().add(
        GetHealthProfileByIdEvent(widget.profile.id!),
      );
    }
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn muốn xóa hồ sơ sức khỏe này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<HealthProfileBloc>().add(
                DeleteHealthProfileEvent(widget.profile.id!),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Info Card
          _buildProfileInfoCard(),
          const SizedBox(height: 16),
          // Body Metrics
          _buildBodyMetricsCard(),
          const SizedBox(height: 16),
          // Body Measurements
          _buildBodyMeasurementsCard(),
          const SizedBox(height: 16),
          // Action Buttons
          Builder(
            builder: (context) {
              final colorScheme = Theme.of(context).colorScheme;
              final textTheme = Theme.of(context).textTheme;

              return Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleUpdate(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Update',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                  image: DecorationImage(
                    image:
                        widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                        ? NetworkImage(widget.imageUrl!)
                        : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, User', // Placeholder
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Gender: Male', // TODO: Get from User Profile
                      style: textTheme.bodyMedium,
                    ),
                    Text(
                      'Birthday: 11/09/2004    Age: 21', // TODO: Get from User Profile
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyMetricsCard() {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HealthMetricCard(
                  label: 'BMI',
                  value: widget.profile.bmi?.toStringAsFixed(0),
                ),
                HealthMetricCard(
                  label: 'WHR',
                  value: widget.profile.whr?.toStringAsFixed(2),
                ),
                HealthMetricCard(
                  label: 'BMR',
                  value: widget.profile.bmr?.toStringAsFixed(0),
                  unit: 'cal',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                HealthMetricCard(
                  label: 'Body Fat',
                  value: widget.profile.bodyFat?.toStringAsFixed(0),
                  unit: '%',
                ),
                HealthMetricCard(
                  label: 'Muscle Mass',
                  value: widget.profile.muscleMass?.toStringAsFixed(0),
                  unit: 'kg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyMeasurementsCard() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Neck: ${widget.profile.neck?.toStringAsFixed(0)}cm'),
                    const SizedBox(height: 8),
                    Text(
                      'Waist: ${widget.profile.waist?.toStringAsFixed(0)}cm',
                    ),
                    const SizedBox(height: 8),
                    Text('Hip: ${widget.profile.hip?.toStringAsFixed(0)}cm'),
                  ],
                ),
              ),
              Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'H: ${widget.profile.height?.toStringAsFixed(0)}cm',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    const Icon(Icons.person_outline, size: 60),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'W: ${widget.profile.weight?.toStringAsFixed(1)}kg',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
