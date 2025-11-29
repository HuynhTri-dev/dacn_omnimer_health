import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';

class HealthProfileEmptyView extends StatefulWidget {
  const HealthProfileEmptyView({super.key});

  @override
  State<HealthProfileEmptyView> createState() => _HealthProfileEmptyViewState();
}

class _HealthProfileEmptyViewState extends State<HealthProfileEmptyView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Health Profile', style: textTheme.headlineMedium),
        const SizedBox(height: 16),
        _buildAddHealthInfoCard(),
      ],
    );
  }

  Widget _buildAddHealthInfoCard() {
    return GestureDetector(
      onTap: () async {
        // Navigate to create profile screen
        final result = await Navigator.pushNamed(
          context,
          RouteConfig.healthProfileForm,
        );

        // If profile created successfully, reload
        if (result == true && mounted) {
          context.read<HealthProfileBloc>().add(
            const GetLatestHealthProfileEvent(),
          );
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Add your health information to start tracking your progress today.',
                    style: textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
