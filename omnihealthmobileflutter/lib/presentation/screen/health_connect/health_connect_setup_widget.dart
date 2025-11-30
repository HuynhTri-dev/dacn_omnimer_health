import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_connect/bloc/health_connect_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

import '../../common/button/button_primary.dart';
import '../../common/skeleton/skeleton_loading.dart';

/// Widget to handle Health Connect setup in the More screen
class HealthConnectSetupWidget extends StatelessWidget {
  final VoidCallback? onNavigateToHealthConnect;

  const HealthConnectSetupWidget({Key? key, this.onNavigateToHealthConnect})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.get<HealthConnectBloc>(),
      child: BlocConsumer<HealthConnectBloc, HealthConnectState>(
        listener: (context, state) {
          if (state is HealthConnectError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildHealthConnectCard(context, state);
        },
      ),
    );
  }

  Widget _buildHealthConnectCard(
    BuildContext context,
    HealthConnectState state,
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
      onTap: onNavigateToHealthConnect,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Health Connect icon
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                'assets/Health_Connect.svg',
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
                    'Health Connect',
                    style: AppTypography.h1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.displayLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Google\'s health data platform',
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

  Widget _buildStatusSection(BuildContext context, HealthConnectState state) {
    if (state is HealthConnectLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: const SkeletonLoading(
          variant: SkeletonVariant.textField,
          height: 20,
        ),
      );
    }

    if (state is HealthConnectAvailable) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildAvailabilityStatus(context, state),
      );
    }

    if (state is HealthConnectUnavailable) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildUnavailabilityStatus(context, state),
      );
    }

    if (state is HealthConnectPermissionsGranted) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: _buildConnectedStatus(context),
      );
    }

    if (state is HealthConnectPermissionsDenied) {
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
    HealthConnectAvailable state,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: state.isInstalled
            ? AppColors.success.withOpacity(0.1)
            : AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            state.isInstalled ? Icons.check_circle : Icons.warning,
            size: 16.w,
            color: state.isInstalled ? AppColors.success : AppColors.warning,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              state.isInstalled
                  ? state.hasPermissions
                        ? 'Health Connect is ready'
                        : 'Permissions required'
                  : 'Health Connect not installed',
              style: AppTypography.bodySmall.copyWith(
                color: state.isInstalled
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
    HealthConnectUnavailable state,
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
              'Health Connect not available',
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
    HealthConnectPermissionsDenied state,
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
              'Checking Health Connect...',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, HealthConnectState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          // Primary action button
          _buildPrimaryActionButton(context, state),

          // Secondary action
          if (state is HealthConnectAvailable && state.hasPermissions) ...[
            SizedBox(height: AppSpacing.sm),
            ButtonPrimary(
              title: 'Manage Settings',
              variant: ButtonVariant.primaryOutline,
              onPressed: onNavigateToHealthConnect,
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
    HealthConnectState state,
  ) {
    if (state is HealthConnectLoading) {
      return ButtonPrimary(
        title: 'Loading...',
        loading: true,
        onPressed: null,
        fullWidth: true,
      );
    }

    if (state is HealthConnectAvailable && !state.hasPermissions) {
      return ButtonPrimary(
        title: 'Request Permissions',
        onPressed: () {
          context.read<HealthConnectBloc>().add(RequestHealthPermissions());
        },
        fullWidth: true,
      );
    }

    if (state is HealthConnectAvailable && !state.isInstalled) {
      return ButtonPrimary(
        title: 'Install Health Connect',
        onPressed: () {
          context.read<HealthConnectBloc>().add(
            CheckHealthConnectAvailability(),
          );
        },
        variant: ButtonVariant.primaryOutline,
        fullWidth: true,
      );
    }

    if (state is HealthConnectPermissionsDenied) {
      return ButtonPrimary(
        title: 'Request Permissions',
        onPressed: () {
          context.read<HealthConnectBloc>().add(RequestHealthPermissions());
        },
        variant: ButtonVariant.dangerSolid,
        fullWidth: true,
      );
    }

    // For initial state or connected state
    return ButtonPrimary(
      title: 'Open Health Connect',
      onPressed: onNavigateToHealthConnect,
      fullWidth: true,
    );
  }
}
