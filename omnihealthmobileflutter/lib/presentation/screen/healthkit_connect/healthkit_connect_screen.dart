import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/presentation/screen/healthkit_connect/bloc/healthkit_connect_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/entities/health_connect_entity.dart';
import '../../common/button/button_primary.dart';
import '../../common/skeleton/skeleton_loading.dart';
import '../../../../injection_container.dart';

class HealthKitConnectScreen extends StatelessWidget {
  const HealthKitConnectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl.get<HealthKitConnectBloc>()..add(CheckHealthKitAvailability()),
      child: const _HealthKitConnectScreenContent(),
    );
  }
}

class _HealthKitConnectScreenContent extends StatefulWidget {
  const _HealthKitConnectScreenContent({Key? key}) : super(key: key);

  @override
  State<_HealthKitConnectScreenContent> createState() =>
      _HealthKitConnectScreenContentState();
}

class _HealthKitConnectScreenContentState
    extends State<_HealthKitConnectScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apple Health'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<HealthKitConnectBloc, HealthKitConnectState>(
          listener: (context, state) {
            if (state is HealthKitConnectError) {
              _showErrorSnackBar(context, state.message);
            } else if (state is HealthKitDataSyncSuccess) {
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
        Image.asset(
          'assets/healthkit_api.png',
          width: 80.w,
          height: 80.w,
          fit: BoxFit.contain,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'Apple Health',
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

  Widget _buildAvailabilitySection(HealthKitConnectState state) {
    if (state is HealthKitConnectLoading) {
      return const SkeletonLoading(variant: SkeletonVariant.card, count: 3);
    }

    if (state is HealthKitConnectUnavailable) {
      return _buildErrorCard(
        icon: Icons.warning_amber_outlined,
        title: 'Apple Health Not Available',
        subtitle: state.message,
        actions: [],
      );
    }

    if (state is HealthKitConnectAvailable) {
      return _buildAvailabilityCard(state);
    }

    if (state is HealthKitConnectPermissionsDenied) {
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
                'Apple Health Status',
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).textTheme.displaySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Checking Apple Health availability...',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(HealthKitConnectAvailable state) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.success),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Apple Health Status',
                style: AppTypography.h3.copyWith(
                  color: Theme.of(context).textTheme.displaySmall?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildStatusRow(
            'Available',
            'Apple Health is available on your device',
            true,
          ),
          _buildStatusRow(
            'Permissions',
            state.hasPermissions ? 'Granted' : 'Not granted',
            state.hasPermissions,
          ),
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

  Widget _buildHealthDataSection(HealthKitConnectState state) {
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

          if (state is HealthKitConnectLoading) ...[
            const Center(child: CircularProgressIndicator()),
          ] else if (state is HealthKitDataLoaded) ...[
            if (state.todayData != null)
              _buildTodayHealthCard(state.todayData!),
            SizedBox(height: AppSpacing.md),
            _buildSyncInfo(),
          ] else if (state is HealthKitConnectPermissionsDenied) ...[
            Text(
              'Enable Apple Health to see your health data',
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

  Widget _buildActionsSection(HealthKitConnectState state) {
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

        if (state is HealthKitConnectAvailable && !state.hasPermissions) ...[
          ButtonPrimary(
            title: 'Request Permissions',
            onPressed: _requestPermissions,
            loading: state is HealthKitConnectLoading,
            fullWidth: true,
          ),
          SizedBox(height: AppSpacing.sm),
        ],

        if (state is HealthKitDataLoaded) ...[
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
                state is HealthKitConnectSyncing &&
                (state as HealthKitConnectSyncing).isSyncing,
            fullWidth: true,
          ),
        ] else if (state is HealthKitConnectAvailable &&
            state.hasPermissions) ...[
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
          if (actions.isNotEmpty) ...[
            SizedBox(height: AppSpacing.lg),
            ...actions.map(
              (action) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: action,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _requestPermissions() {
    context.read<HealthKitConnectBloc>().add(RequestHealthKitPermissions());
  }

  void _loadHealthData() {
    context.read<HealthKitConnectBloc>().add(GetTodayHealthKitData());
  }

  void _refreshHealthData() {
    context.read<HealthKitConnectBloc>().add(GetTodayHealthKitData());
  }

  void _syncToBackend() {
    context.read<HealthKitConnectBloc>().add(SyncHealthKitDataToBackend());
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
