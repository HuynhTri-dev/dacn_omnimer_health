import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/change_password/cubits/change_password_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/change_password/cubits/change_password_state.dart';

/// Change Password Screen - Update current password
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChangePasswordCubit>(),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView({Key? key}) : super(key: key);

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicator
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _newPasswordController.text;
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = '';
    } else if (password.length < 6) {
      strength = 0.25;
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strength = 0.5;
      strengthText = 'Fair';
      strengthColor = Colors.orange;
    } else {
      // Check for uppercase, lowercase, numbers, and special characters
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters = password.contains(
        RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
      );

      int criteriaCount = [
        hasUppercase,
        hasLowercase,
        hasDigits,
        hasSpecialCharacters,
      ].where((element) => element).length;

      if (criteriaCount >= 3) {
        strength = 1.0;
        strengthText = 'Strong';
        strengthColor = Colors.green;
      } else if (criteriaCount >= 2) {
        strength = 0.75;
        strengthText = 'Good';
        strengthColor = Colors.blue;
      } else {
        strength = 0.5;
        strengthText = 'Fair';
        strengthColor = Colors.orange;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
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
          'Change Password',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            _showSnackBar(context, state.message, isSuccess: true);
            // Clear fields
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmPasswordController.clear();
            // Navigate back after a short delay
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is ChangePasswordError) {
            _showSnackBar(context, state.message, isSuccess: false);
          }
        },
        builder: (context, state) {
          final isLoading = state is ChangePasswordLoading;

          return SingleChildScrollView(
            padding: AppSpacing.paddingMd,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Security Info Card
                  _buildSecurityInfoCard(context),

                  SizedBox(height: AppSpacing.lg),

                  // Current Password Field
                  _buildPasswordField(
                    context,
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    obscureText: _obscureCurrentPassword,
                    enabled: !isLoading,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.md),

                  // New Password Field
                  _buildPasswordField(
                    context,
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter your new password',
                    obscureText: _obscureNewPassword,
                    enabled: !isLoading,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (value == _currentPasswordController.text) {
                        return 'New password must be different from current password';
                      }
                      return null;
                    },
                  ),

                  // Password Strength Indicator
                  if (_newPasswordController.text.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.sm),
                    _buildPasswordStrengthIndicator(context),
                  ],

                  SizedBox(height: AppSpacing.md),

                  // Confirm Password Field
                  _buildPasswordField(
                    context,
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter your new password',
                    obscureText: _obscureConfirmPassword,
                    enabled: !isLoading,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Password Requirements
                  _buildPasswordRequirements(context),

                  SizedBox(height: AppSpacing.xl),

                  // Change Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusMd,
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              'Change Password',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Forgot Password Link
                  Center(
                    child: TextButton(
                      onPressed: isLoading ? null : _forgotPassword,
                      child: Text(
                        'Forgot your current password?',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecurityInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24.sp),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Choose a strong password to keep your account secure',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required bool enabled,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.primary),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          onPressed: onToggleVisibility,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.radiusSm,
                child: LinearProgressIndicator(
                  value: _passwordStrength,
                  backgroundColor: colorScheme.outline.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _passwordStrengthColor,
                  ),
                  minHeight: 6.h,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              _passwordStrengthText,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _passwordStrengthColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildRequirementItem(context, 'At least 8 characters'),
          _buildRequirementItem(context, 'Contains uppercase letter (A-Z)'),
          _buildRequirementItem(context, 'Contains lowercase letter (a-z)'),
          _buildRequirementItem(context, 'Contains number (0-9)'),
          _buildRequirementItem(
            context,
            'Contains special character (!@#\$%^&*)',
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ChangePasswordCubit>().changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  void _forgotPassword() {
    Navigator.pushNamed(context, '/forget-password');
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
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
}
