import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/verification_status_entity.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/verify_account/cubits/verify_account_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/verify_account/cubits/verify_account_state.dart';

/// Verify Account Screen - Email verification and authentication methods
class VerifyAccountScreen extends StatelessWidget {
  const VerifyAccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<VerifyAccountCubit>()..loadVerificationStatus(),
      child: const _VerifyAccountView(),
    );
  }
}

class _VerifyAccountView extends StatefulWidget {
  const _VerifyAccountView({Key? key}) : super(key: key);

  @override
  State<_VerifyAccountView> createState() => _VerifyAccountViewState();
}

class _VerifyAccountViewState extends State<_VerifyAccountView> {
  bool _isTwoFactorEnabled = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Account',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<VerifyAccountCubit, VerifyAccountState>(
        listener: (context, state) {
          if (state is VerifyAccountEmailSent) {
            _showSnackBar(context, state.message, isSuccess: true);
          } else if (state is VerifyAccountChangeEmailSent) {
            _showSnackBar(context, state.message, isSuccess: true);
            _emailController.clear();
          } else if (state is VerifyAccountError) {
            _showSnackBar(context, state.message, isSuccess: false);
          }
        },
        builder: (context, state) {
          if (state is VerifyAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          VerificationStatusEntity? status;
          if (state is VerifyAccountLoaded) {
            status = state.status;
          } else if (state is VerifyAccountEmailSent) {
            status = state.status;
          } else if (state is VerifyAccountError) {
            status = state.previousStatus;
          }

          final isEmailSending = state is VerifyAccountEmailSending;
          final isChangeEmailSending = state is VerifyAccountChangeEmailSending;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<VerifyAccountCubit>().loadVerificationStatus(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Email Verification Section
                  _buildSectionHeader(context, 'Email Verification'),
                  SizedBox(height: AppSpacing.sm),
                  _buildEmailVerificationCard(
                    context,
                    status: status,
                    isLoading: isEmailSending,
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Change Email Section
                  _buildSectionHeader(context, 'Change Email'),
                  SizedBox(height: AppSpacing.sm),
                  _buildChangeEmailCard(
                    context,
                    currentEmail: status?.email,
                    isLoading: isChangeEmailSending,
                  ),

                  SizedBox(height: AppSpacing.lg),

                  // Two-Factor Authentication Section
                  _buildSectionHeader(context, 'Two-Factor Authentication'),
                  SizedBox(height: AppSpacing.sm),
                  _buildTwoFactorCard(context),

                  SizedBox(height: AppSpacing.lg),

                  // Authentication Methods Section
                  _buildSectionHeader(context, 'Authentication Methods'),
                  SizedBox(height: AppSpacing.sm),
                  _buildAuthMethodsCard(context),

                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildEmailVerificationCard(
    BuildContext context, {
    VerificationStatusEntity? status,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isVerified = status?.isEmailVerified ?? false;
    final email = status?.maskedEmail ?? 'Loading...';

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: (isVerified ? Colors.green : Colors.orange)
                      .withOpacity(0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  isVerified ? Icons.verified : Icons.warning_amber_rounded,
                  color: isVerified ? Colors.green : Colors.orange,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVerified ? 'Email Verified' : 'Email Not Verified',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: textTheme.bodySmall?.copyWith(
                        color: textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
            ],
          ),
          if (!isVerified) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<VerifyAccountCubit>()
                        .sendVerificationEmail(),
                icon: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.email_outlined),
                label: Text(isLoading ? 'Sending...' : 'Send Verification Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () => context
                        .read<VerifyAccountCubit>()
                        .resendVerificationEmail(),
                child: Text(
                  'Resend verification email',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeEmailCard(
    BuildContext context, {
    String? currentEmail,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentEmail != null && currentEmail.isNotEmpty) ...[
            Text(
              'Current email: $currentEmail',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
          ],
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'New Email Address',
              hintText: 'Enter new email',
              prefixIcon: Icon(Icons.email_outlined, color: colorScheme.primary),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => context
                      .read<VerifyAccountCubit>()
                      .requestChangeEmail(_emailController.text.trim()),
              icon: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.swap_horiz),
              label: Text(isLoading ? 'Sending...' : 'Request Email Change'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(Icons.security, color: colorScheme.primary, size: 24.sp),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Two-Factor Authentication',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add an extra layer of security',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: _isTwoFactorEnabled,
            onChanged: (value) {
              setState(() {
                _isTwoFactorEnabled = value;
              });
              _showComingSoonSnackbar(context, 'Two-Factor Authentication');
            },
            activeColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAuthMethodItem(
            context,
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID',
            onTap: () => _showComingSoonSnackbar(context, 'Biometric'),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildAuthMethodItem(
            context,
            icon: Icons.phone_android,
            title: 'SMS Authentication',
            subtitle: 'Verify with SMS code',
            onTap: () => _showComingSoonSnackbar(context, 'SMS'),
          ),
          Divider(height: 1, color: theme.dividerColor),
          _buildAuthMethodItem(
            context,
            icon: Icons.qr_code,
            title: 'Authenticator App',
            subtitle: 'Use Google Authenticator or similar',
            onTap: () => _showComingSoonSnackbar(context, 'Authenticator App'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textTheme.bodySmall?.color?.withOpacity(0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isSuccess = true}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
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
