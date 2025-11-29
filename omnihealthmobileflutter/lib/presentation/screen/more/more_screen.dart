import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/bloc/more_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/bloc/more_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/bloc/more_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/more_menu_item.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/more_section_header.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/account_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/health_data_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/settings_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/support_section.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';

/// More Screen - Settings & Utilities
/// Includes: Profile, Privacy, Device Connectivity, Theme, Premium, Support
class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoreBloc()..add(const LoadMoreSettings()),
      child: Scaffold(
        body: Column(
          children: [
            // User Header
            const UserHeaderWidget(),

            // Content
            Expanded(
              child: BlocBuilder<MoreBloc, MoreState>(
                builder: (context, state) {
                  if (state is MoreLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is MoreError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  }

                  if (state is MoreLoaded) {
                    return _buildContent(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MoreLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Account
          const MoreSectionHeader(title: 'ACCOUNT'),
          AccountSection(onPremiumTap: () => _handlePremiumTap(context)),

          // Section: Health & Data
          const MoreSectionHeader(title: 'HEALTH & DATA'),
          HealthDataSection(
            onDeviceConnectivityTap: () =>
                _handleDeviceConnectivityTap(context),
            onPrivacyTap: () => _handlePrivacyTap(context),
            onExportDataTap: () => _handleExportDataTap(context),
          ),

          // Section: Settings
          const MoreSectionHeader(title: 'SETTINGS'),
          SettingsSection(
            state: state,
            onThemeTap: () => _handleThemeTap(context),
            onLanguageTap: () => _handleLanguageTap(context),
            onNotificationsTap: () => _handleNotificationsTap(context, state),
          ),

          // Section: Support
          const MoreSectionHeader(title: 'SUPPORT'),
          SupportSection(
            onRateUsTap: () => _handleRateUsTap(context),
            onFeedbackTap: () => _handleFeedbackTap(context),
            onAboutTap: () => _handleAboutTap(context),
          ),

          SizedBox(height: AppSpacing.lg),

          // Logout Button
          _buildLogoutButton(context),

          SizedBox(height: AppSpacing.md),

          // Version Info
          _buildVersionInfo(),

          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MoreMenuItem(
      icon: Icons.logout_outlined,
      title: 'Logout',
      subtitle: 'Sign out from current account',
      iconColor: colorScheme.error,
      backgroundColor: colorScheme.error.withOpacity(0.1),
      showArrow: false,
      onTap: () => _handleLogoutTap(context),
    );
  }

  Widget _buildVersionInfo() {
    return Builder(
      builder: (context) => Center(
        child: Text(
          'OmniMer Health v1.0.0',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  // Navigation handlers
  void _handlePremiumTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Premium Upgrade');
  }

  void _handleDeviceConnectivityTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Device Connectivity');
  }

  void _handlePrivacyTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Privacy & LOD');
  }

  void _handleExportDataTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Export Data');
  }

  void _handleThemeTap(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Text(
          'Select Theme',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              context,
              icon: Icons.light_mode,
              title: 'Light',
              themeMode: 'light',
            ),
            SizedBox(height: AppSpacing.xs),
            _buildThemeOption(
              context,
              icon: Icons.dark_mode,
              title: 'Dark',
              themeMode: 'dark',
            ),
            SizedBox(height: AppSpacing.xs),
            _buildThemeOption(
              context,
              icon: Icons.brightness_auto,
              title: 'System Default',
              themeMode: 'system',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String themeMode,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        context.read<MoreBloc>().add(ToggleThemeMode(themeMode));

        // Update ThemeCubit
        ThemeMode mode;
        switch (themeMode) {
          case 'light':
            mode = ThemeMode.light;
            break;
          case 'dark':
            mode = ThemeMode.dark;
            break;
          default:
            mode = ThemeMode.system;
        }
        context.read<ThemeCubit>().setTheme(mode);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme selected: $title'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            margin: AppSpacing.paddingMd,
          ),
        );
      },
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24.sp),
            SizedBox(width: AppSpacing.sm),
            Text(title, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _handleLanguageTap(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Text(
          'Select Language',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'Vietnamese', 'vi'),
            SizedBox(height: AppSpacing.xs),
            _buildLanguageOption(context, 'English', 'en'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String title,
    String languageCode,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: () {
        context.read<MoreBloc>().add(ChangeLanguage(languageCode));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language selected: $title'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            margin: AppSpacing.paddingMd,
          ),
        );
      },
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          children: [
            Icon(Icons.language, color: colorScheme.primary, size: 24.sp),
            SizedBox(width: AppSpacing.sm),
            Text(title, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _handleNotificationsTap(BuildContext context, MoreLoaded state) {
    _showComingSoonSnackbar(context, 'Notification Settings');
  }

  void _handleRateUsTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Rate App');
  }

  void _handleFeedbackTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'Send Feedback');
  }

  void _handleAboutTap(BuildContext context) {
    _showComingSoonSnackbar(context, 'About');
  }

  void _handleLogoutTap(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Text(
          'Logout',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(
              'Cancel',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthenticationBloc>().add(AuthenticationLoggedOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            child: Text(
              'Logout',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }
}
