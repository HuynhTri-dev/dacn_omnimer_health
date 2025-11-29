import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/presentation/screen/healthkit_connect/bloc/healthkit_connect_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

import '../../common/button/button_primary.dart';
import '../../common/skeleton/skeleton_loading.dart';

/// Widget to handle HealthKit setup in the More screen
class HealthKitConnectSetupWidget extends StatelessWidget {
  final VoidCallback? onNavigateToHealthKit;

  const HealthKitConnectSetupWidget({Key? key, this.onNavigateToHealthKit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl.get<HealthKitConnectBloc>()..add(CheckHealthKitAvailability()),
      child: BlocConsumer<HealthKitConnectBloc, HealthKitConnectState>(
        listener: (context, state) {
          if (state is HealthKitConnectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildHealthKitCard(context, state);
        },
      ),
    );
  }

  Widget _buildHealthKitCard(
    BuildContext context,
    HealthKitConnectState state,
  ) {
    return Container(
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
          // Header with icon and title
          _buildHeader(context),

          // Status section
          SizedBox(height: AppSpacing.md),
          _buildStatusSection(context, state),

          // Actions section
          SizedBox(height: AppSpacing.lg),
          _buildActionsSection(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: onNavigateToHealthKit,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // HealthKit icon
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/healthkit_api.png',
                width: 24.w,
                height: 24.w,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(width: AppSpacing.md),

            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apple Health',
                    style: AppTypography.h1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Sync your health data',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(
    BuildContext context,
    HealthKitConnectState state,
  ) {
    if (state is HealthKitConnectLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: const SkeletonLoading(
          variant: SkeletonVariant.textField,
          height: 20,
        ),
      );
    }

    if (state is HealthKitConnectAvailable) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildAvailabilityStatus(context, state),
      );
    }

    if (state is HealthKitConnectUnavailable) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildUnavailabilityStatus(context, state),
      );
    }

    if (state is HealthKitConnectPermissionsGranted) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildConnectedStatus(context),
      );
    }

    if (state is HealthKitConnectPermissionsDenied) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildDeniedStatus(context, state),
      );
    }

    // Initial state - check availability
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: _buildInitialStatus(context),
    );
  }

  Widget _buildAvailabilityStatus(
    BuildContext context,
    HealthKitConnectAvailable state,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: state.hasPermissions
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            state.hasPermissions ? Icons.check_circle : Icons.warning,
            size: 16.w,
            color: state.hasPermissions ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              state.hasPermissions
                  ? 'Apple Health is ready'
                  : 'Permissions required',
              style: AppTypography.bodySmall.copyWith(
                color: state.hasPermissions
                    ? AppColors.success
                    : AppColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailabilityStatus(
    BuildContext context,
    HealthKitConnectUnavailable state,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16.w,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Apple Health not available',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16.w, color: AppColors.success),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Connected and permissions granted',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeniedStatus(
    BuildContext context,
    HealthKitConnectPermissionsDenied state,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.block,
            size: 16.w,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Permissions denied',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialStatus(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Checking Apple Health...',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(
    BuildContext context,
    HealthKitConnectState state,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Primary action button
          _buildPrimaryActionButton(context, state),

          // Secondary action
          if (state is HealthKitConnectAvailable && state.hasPermissions) ...[
            SizedBox(height: AppSpacing.sm),
            ButtonPrimary(
              title: 'Manage Settings',
              variant: ButtonVariant.primaryOutline,
              onPressed: onNavigateToHealthKit,
              size: ButtonSize.small,
            ),
          ],

          SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    BuildContext context,
    HealthKitConnectState state,
  ) {
    if (state is HealthKitConnectLoading) {
      return ButtonPrimary(
        title: 'Loading...',
        loading: true,
        onPressed: null,
        fullWidth: true,
      );
    }

    if (state is HealthKitConnectAvailable && !state.hasPermissions) {
      return ButtonPrimary(
        title: 'Request Permissions',
        onPressed: () {
          context.read<HealthKitConnectBloc>().add(
            RequestHealthKitPermissions(),
          );
        },
        fullWidth: true,
      );
    }

    if (state is HealthKitConnectPermissionsDenied) {
      return ButtonPrimary(
        title: 'Request Permissions',
        onPressed: () {
          context.read<HealthKitConnectBloc>().add(
            RequestHealthKitPermissions(),
          );
        },
        variant: ButtonVariant.dangerSolid,
        fullWidth: true,
      );
    }

    // For initial state or connected state
    return ButtonPrimary(
      title: 'Open Apple Health Settings',
      onPressed: onNavigateToHealthKit,
      fullWidth: true,
    );
  }
}
