import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/app_strings.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/policy_viewer_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/widgets/legal_documents_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/privacy_lod/widgets/data_visibility_section.dart';

/// Privacy & LOD Screen
/// Manages privacy settings, data visibility, and legal documents
class PrivacyLodScreen extends StatelessWidget {
  const PrivacyLodScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppStrings.privacyTitle,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, authState) {
          bool isDataSharingAccepted = false;
          if (authState is AuthenticationAuthenticated) {
            isDataSharingAccepted = authState.user.isDataSharingAccepted;
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Legal Documents
                _buildSectionHeader(
                  context,
                  icon: Icons.gavel,
                  title: AppStrings.legalDocuments,
                ),
                SizedBox(height: AppSpacing.sm),
                LegalDocumentsSection(
                  isPrivacyAccepted: isDataSharingAccepted,
                  onPrivacyPolicyTap: () => _navigateToPolicyViewer(
                    context,
                    PolicyType.privacyPolicy,
                  ),
                ),

                SizedBox(height: AppSpacing.xl),

                // Section: Data Visibility
                _buildSectionHeader(
                  context,
                  icon: Icons.visibility,
                  title: AppStrings.dataVisibility,
                  subtitle: AppStrings.dataVisibilitySubtitle,
                ),
                SizedBox(height: AppSpacing.sm),
                DataVisibilitySection(
                  isDataSharingAccepted: isDataSharingAccepted,
                ),

                SizedBox(height: AppSpacing.xl),

                // Info card
                _buildInfoCard(context),

                SizedBox(height: AppSpacing.xl),

                // Toggle Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isDataSharingAccepted) {
                        // If currently accepted, toggle to turn off
                        context.read<AuthenticationBloc>().add(
                          AuthenticationToggleDataSharing(),
                        );
                      } else {
                        // If not accepted, navigate to privacy policy to accept
                        _navigateToPolicyViewer(
                          context,
                          PolicyType.privacyPolicy,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDataSharingAccepted
                          ? colorScheme.error
                          : colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                    child: Text(
                      isDataSharingAccepted
                          ? AppStrings.stopSharing
                          : AppStrings.enableSharing,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
          Icon(icon, size: 20.sp, color: colorScheme.primary),
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
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
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
                AppStrings.yourDataProtected,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.privacyDescription,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildFeatureChip(context, AppStrings.encrypted),
              SizedBox(width: AppSpacing.xs),
              _buildFeatureChip(context, AppStrings.secure),
              SizedBox(width: AppSpacing.xs),
              _buildFeatureChip(context, AppStrings.noAds),
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
        builder: (newContext) => PolicyViewerScreen(policyType: type),
      ),
    ).then((value) {
      // Check if user accepted the policy
      if (value == true) {
        context.read<AuthenticationBloc>().add(
          AuthenticationToggleDataSharing(),
        );
      }
    });
  }
}
