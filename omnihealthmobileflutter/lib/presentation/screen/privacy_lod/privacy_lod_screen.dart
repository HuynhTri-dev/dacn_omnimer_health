import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/bloc/privacy_lod_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/bloc/privacy_lod_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/bloc/privacy_lod_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/policy_viewer_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/widgets/legal_documents_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/widgets/data_visibility_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/widgets/anonymize_section.dart';

/// Privacy & LOD Screen
/// Manages privacy settings, data visibility, and legal documents
class PrivacyLodScreen extends StatelessWidget {
  const PrivacyLodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PrivacyLodBloc()..add(const LoadPrivacySettings()),
      child: const _PrivacyLodView(),
    );
  }
}

class _PrivacyLodView extends StatelessWidget {
  const _PrivacyLodView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Privacy & Data',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PrivacyLodBloc, PrivacyLodState>(
        builder: (context, state) {
          if (state is PrivacyLodLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PrivacyLodError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: colorScheme.error,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    state.message,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<PrivacyLodBloc>()
                          .add(const LoadPrivacySettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PrivacyLodLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PrivacyLodLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Legal Documents
          _buildSectionHeader(
            context,
            icon: Icons.gavel,
            title: 'Legal Documents',
          ),
          SizedBox(height: AppSpacing.sm),
          LegalDocumentsSection(
            isPrivacyAccepted: state.isPrivacyPolicyAccepted,
            isTermsAccepted: state.isTermsAccepted,
            onPrivacyPolicyTap: () => _navigateToPolicyViewer(
              context,
              PolicyType.privacyPolicy,
            ),
            onTermsOfServiceTap: () => _navigateToPolicyViewer(
              context,
              PolicyType.termsOfService,
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Section: Data Visibility
          _buildSectionHeader(
            context,
            icon: Icons.visibility,
            title: 'Data Visibility',
            subtitle: 'Control which data can be shared',
          ),
          SizedBox(height: AppSpacing.sm),
          DataVisibilitySection(
            settings: state.dataVisibility,
            onToggle: (dataType, value) {
              context.read<PrivacyLodBloc>().add(
                    ToggleDataVisibility(
                      dataType: dataType,
                      isVisible: value,
                    ),
                  );
            },
          ),

          SizedBox(height: AppSpacing.xl),

          // Section: Anonymization
          _buildSectionHeader(
            context,
            icon: Icons.security,
            title: 'Data Protection',
          ),
          SizedBox(height: AppSpacing.sm),
          AnonymizeSection(
            isEnabled: state.isAnonymizeEnabled,
            onChanged: (value) {
              context.read<PrivacyLodBloc>().add(
                    ToggleAnonymizeData(isAnonymized: value),
                  );
            },
          ),

          SizedBox(height: AppSpacing.xl),

          // Info card
          _buildInfoCard(context),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.5),
            colorScheme.secondaryContainer.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Your Data is Protected',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'We take your privacy seriously. Your health data is encrypted and securely stored. We never sell your personal information to third parties.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildFeatureChip(context, '🔒 Encrypted'),
              SizedBox(width: AppSpacing.xs),
              _buildFeatureChip(context, '🛡️ Secure'),
              SizedBox(width: AppSpacing.xs),
              _buildFeatureChip(context, '🚫 No Ads'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToPolicyViewer(BuildContext context, PolicyType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (newContext) => BlocProvider.value(
          value: context.read<PrivacyLodBloc>(),
          child: PolicyViewerScreen(policyType: type),
        ),
      ),
    );
  }
}

