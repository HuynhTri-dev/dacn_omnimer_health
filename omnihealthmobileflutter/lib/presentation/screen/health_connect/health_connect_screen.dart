import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_connect/bloc/health_connect_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/health_connect_entity.dart';
import '../../common/button/button_primary.dart';
import '../../common/skeleton/skeleton_loading.dart';
import '../../../../injection_container.dart';

class HealthConnectScreen extends StatelessWidget {
  const HealthConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl.get<HealthConnectBloc>()..add(CheckHealthConnectAvailability()),
      child: const _HealthConnectScreenContent(),
    );
  }
}

class _HealthConnectScreenContent extends StatefulWidget {
  const _HealthConnectScreenContent({Key? key}) : super(key: key);

  @override
  State<_HealthConnectScreenContent> createState() =>
      _HealthConnectScreenContentState();
}

class _HealthConnectScreenContentState
    extends State<_HealthConnectScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Connect'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<HealthConnectBloc, HealthConnectState>(
          listener: (context, state) {
            if (state is HealthConnectError) {
              _showErrorSnackBar(context, state.message);
            } else if (state is HealthDataSyncSuccess) {
              _showSuccessSnackBar(context, 'Health data synced successfully!');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: AppSpacing.xl),
                  _buildAvailabilitySection(state),
                  SizedBox(height: AppSpacing.xl),
                  _buildHealthDataSection(state),
                  SizedBox(height: AppSpacing.xl),
                  _buildActionsSection(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          'assets/Health_Connect.svg',
          width: 80.w,
          height: 80.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Google Health Connect',
          style: AppTypography.h1.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.displayLarge?.color,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Connect your health data to sync steps, heart rate, sleep, and more with your Omnimer profile.',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection(HealthConnectState state) {
    if (state is HealthConnectLoading) {
      return const SkeletonLoading(variant: SkeletonVariant.card, count: 3);
    }

    if (state is HealthConnectUnavailable) {
      return _buildErrorCard(
        icon: Icons.warning_amber_outlined,
        title: 'Health Connect Not Available',
        subtitle: state.message,
        actions: [
          ButtonPrimary(
            title: 'Install Health Connect',
            onPressed: _installHealthConnect,
            variant: ButtonVariant.primaryOutline,
            fullWidth: true,
          ),
        ],
      );
    }

    if (state is HealthConnectAvailable) {
      return _buildAvailabilityCard(state);
    }

    if (state is HealthConnectPermissionsDenied) {
      return _buildErrorCard(
        icon: Icons.block,
        title: 'Permissions Denied',
        subtitle: state.message,
        actions: [
          ButtonPrimary(
            title: 'Request Permissions',
            onPressed: _requestPermissions,
            fullWidth: true,
          ),
        ],
      );
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Health Connect Status',
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).textTheme.displaySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Checking Health Connect availability...',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(HealthConnectAvailable state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                state.isInstalled
                    ? Icons.check_circle_outline
                    : Icons.warning_amber_outlined,
                color: state.isInstalled
                    ? AppColors.success
                    : AppColors.warning,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Health Connect Status',
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).textTheme.displaySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (state.isInstalled) ...[
            _buildStatusRow(
              'Installed',
              'Health Connect is installed on your device',
              true,
            ),
            _buildStatusRow(
              'Permissions',
              state.hasPermissions ? 'Granted' : 'Not granted',
              state.hasPermissions,
            ),
          ] else ...[
            _buildStatusRow(
              'Installed',
              'Health Connect is not installed',
              false,
            ),
            SizedBox(height: AppSpacing.md),
            ButtonPrimary(
              title: 'Install Health Connect',
              onPressed: _installHealthConnect,
              variant: ButtonVariant.primaryOutline,
              fullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isSuccess) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 16.w,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$label: $value',
              style: AppTypography.bodyMedium.copyWith(
                color: isSuccess ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDataSection(HealthConnectState state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Health Data',
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).textTheme.displaySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),

          if (state is HealthConnectLoading) ...[
            const Center(child: CircularProgressIndicator()),
          ] else if (state is HealthDataLoaded) ...[
            if (state.todayData != null)
              _buildTodayHealthCard(state.todayData!),
            SizedBox(height: AppSpacing.md),
            _buildSyncInfo(),
          ] else if (state is HealthConnectPermissionsDenied) ...[
            Text(
              'Enable Health Connect to see your health data',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ] else ...[
            Text(
              'No health data available',
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodayHealthCard(HealthConnectData data) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Health Data',
            style: AppTypography.h4.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              if (data.steps != null)
                _buildMetricCard('Steps', '${data.steps}'),
              if (data.distance != null)
                _buildMetricCard(
                  'Distance',
                  '${data.distance?.toStringAsFixed(1)} km',
                ),
              if (data.caloriesBurned != null)
                _buildMetricCard('Calories', '${data.caloriesBurned}'),
              if (data.heartRateAvg != null)
                _buildMetricCard('Heart Rate', '${data.heartRateAvg} bpm'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncInfo() {
    return Row(
      children: [
        Icon(
          Icons.sync,
          size: 16.w,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          'Health data is synced automatically',
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(HealthConnectState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions',
          style: AppTypography.h3.copyWith(
            color: Theme.of(context).textTheme.displaySmall?.color,
          ),
        ),
        SizedBox(height: AppSpacing.md),

        if (state is HealthConnectAvailable && !state.hasPermissions) ...[
          ButtonPrimary(
            title: 'Request Permissions',
            onPressed: _requestPermissions,
            loading: state is HealthConnectLoading,
            fullWidth: true,
          ),
          SizedBox(height: AppSpacing.sm),
        ],

        if (state is HealthDataLoaded) ...[
          ButtonPrimary(
            title: 'Refresh Health Data',
            onPressed: _refreshHealthData,
            variant: ButtonVariant.primaryOutline,
            fullWidth: true,
          ),
          SizedBox(height: AppSpacing.sm),
          ButtonPrimary(
            title: 'Sync to Backend',
            onPressed: _syncToBackend,
            loading:
                state is HealthConnectSyncing &&
                (state as HealthConnectSyncing).isSyncing,
            fullWidth: true,
          ),
        ] else if (state is HealthConnectAvailable && state.hasPermissions) ...[
          ButtonPrimary(
            title: 'Load Health Data',
            onPressed: _loadHealthData,
            fullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: child,
    );
  }

  Widget _buildErrorCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> actions,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.error),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            subtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          ...actions.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: action,
            ),
          ),
        ],
      ),
    );
  }

  void _installHealthConnect() {
    context.read<HealthConnectBloc>().add(CheckHealthConnectAvailability());
  }

  void _requestPermissions() {
    context.read<HealthConnectBloc>().add(RequestHealthPermissions());
  }

  void _loadHealthData() {
    context.read<HealthConnectBloc>().add(GetTodayHealthData());
  }

  void _refreshHealthData() {
    context.read<HealthConnectBloc>().add(GetTodayHealthData());
  }

  void _syncToBackend() {
    context.read<HealthConnectBloc>().add(SyncHealthDataToBackend());
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
