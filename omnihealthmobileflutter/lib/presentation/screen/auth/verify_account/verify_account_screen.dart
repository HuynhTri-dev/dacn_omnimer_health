import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';

/// Verify Account Screen - Email verification and authentication methods
class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({Key? key}) : super(key: key);

  @override
  State<VerifyAccountScreen> createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  bool _isEmailVerified = false;
  bool _isTwoFactorEnabled = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Account',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email Verification Section
            _buildSectionHeader('Email Verification'),
            SizedBox(height: AppSpacing.sm),
            _buildEmailVerificationCard(),

            SizedBox(height: AppSpacing.lg),

            // Change Email Section
            _buildSectionHeader('Change Email'),
            SizedBox(height: AppSpacing.sm),
            _buildChangeEmailCard(),

            SizedBox(height: AppSpacing.lg),

            // Two-Factor Authentication Section
            _buildSectionHeader('Two-Factor Authentication'),
            SizedBox(height: AppSpacing.sm),
            _buildTwoFactorCard(),

            SizedBox(height: AppSpacing.lg),

            // Authentication Methods Section
            _buildSectionHeader('Authentication Methods'),
            SizedBox(height: AppSpacing.sm),
            _buildAuthMethodsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.headingBoldStyle(
        fontSize: AppTypography.fontSizeBase.sp,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEmailVerificationCard() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
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
              Icon(
                _isEmailVerified ? Icons.verified : Icons.warning_amber_rounded,
                color: _isEmailVerified ? AppColors.success : AppColors.warning,
                size: 24.sp,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEmailVerified
                          ? 'Email Verified'
                          : 'Email Not Verified',
                      style: AppTypography.bodyBoldStyle(
                        fontSize: AppTypography.fontSizeBase.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _isEmailVerified
                          ? 'Your email has been verified'
                          : 'Please verify your email address',
                      style: AppTypography.bodyRegularStyle(
                        fontSize: AppTypography.fontSizeSm.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isEmailVerified) ...[
            SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendVerificationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Send Verification Email',
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeBase.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangeEmailCard() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'New Email Address',
              hintText: 'Enter new email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMd,
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _changeEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
              ),
              child: Text(
                'Change Email',
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoFactorCard() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: AppColors.primary, size: 24.sp),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Two-Factor Authentication',
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeBase.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Add an extra layer of security',
                  style: AppTypography.bodyRegularStyle(
                    fontSize: AppTypography.fontSizeSm.sp,
                    color: AppColors.textSecondary,
                  ),
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
              _toggleTwoFactor(value);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAuthMethodItem(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face ID',
            onTap: _setupBiometric,
          ),
          Divider(height: 1, color: AppColors.border),
          _buildAuthMethodItem(
            icon: Icons.phone_android,
            title: 'SMS Authentication',
            subtitle: 'Verify with SMS code',
            onTap: _setupSMS,
          ),
          Divider(height: 1, color: AppColors.border),
          _buildAuthMethodItem(
            icon: Icons.qr_code,
            title: 'Authenticator App',
            subtitle: 'Use Google Authenticator or similar',
            onTap: _setupAuthenticatorApp,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthMethodItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: AppRadius.radiusSm,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeSm.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMuted,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _sendVerificationEmail() {
    // TODO: Implement send verification email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Verification email sent!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _changeEmail() {
    // TODO: Implement change email
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a new email address'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          margin: AppSpacing.paddingMd,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email change request sent!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _toggleTwoFactor(bool enabled) {
    // TODO: Implement two-factor toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Two-factor authentication enabled'
              : 'Two-factor authentication disabled',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _setupBiometric() {
    // TODO: Implement biometric setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Biometric authentication - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _setupSMS() {
    // TODO: Implement SMS setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('SMS authentication - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _setupAuthenticatorApp() {
    // TODO: Implement authenticator app setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Authenticator app - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }
}
