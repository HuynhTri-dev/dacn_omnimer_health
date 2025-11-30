import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_cubit.dart';

/// Step 3: Enter new password
class EnterNewPasswordStep extends StatefulWidget {
  final bool isLoading;

  const EnterNewPasswordStep({Key? key, required this.isLoading})
      : super(key: key);

  @override
  State<EnterNewPasswordStep> createState() => _EnterNewPasswordStepState();
}

class _EnterNewPasswordStepState extends State<EnterNewPasswordStep> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.red;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;
    String strengthText = '';
    Color strengthColor = Colors.red;

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = '';
    } else if (password.length < 6) {
      strength = 0.25;
      strengthText = 'Yếu';
      strengthColor = Colors.red;
    } else if (password.length < 8) {
      strength = 0.5;
      strengthText = 'Trung bình';
      strengthColor = Colors.orange;
    } else {
      bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = password.contains(RegExp(r'[a-z]'));
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      bool hasSpecialCharacters =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      int criteriaCount = [
        hasUppercase,
        hasLowercase,
        hasDigits,
        hasSpecialCharacters,
      ].where((element) => element).length;

      if (criteriaCount >= 3) {
        strength = 1.0;
        strengthText = 'Mạnh';
        strengthColor = Colors.green;
      } else if (criteriaCount >= 2) {
        strength = 0.75;
        strengthText = 'Khá tốt';
        strengthColor = Colors.blue;
      } else {
        strength = 0.5;
        strengthText = 'Trung bình';
        strengthColor = Colors.orange;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthText = strengthText;
      _passwordStrengthColor = strengthColor;
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<ForgotPasswordCubit>()
          .resetPassword(_passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSpacing.xl.h),

            // Icon
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset_outlined,
                size: 48.sp,
                color: colorScheme.primary,
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Title
            Text(
              'Tạo mật khẩu mới',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: AppSpacing.sm.h),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
              child: Text(
                'Mật khẩu mới phải có ít nhất 6 ký tự và khác mật khẩu cũ.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // New Password Field
            _buildPasswordField(
              controller: _passwordController,
              label: 'Mật khẩu mới',
              hint: 'Nhập mật khẩu mới',
              obscureText: _obscurePassword,
              onToggleVisibility: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
              colorScheme: colorScheme,
            ),

            // Password Strength Indicator
            if (_passwordController.text.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm.h),
              _buildPasswordStrengthIndicator(colorScheme, textTheme),
            ],

            SizedBox(height: AppSpacing.md.h),

            // Confirm Password Field
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Xác nhận mật khẩu',
              hint: 'Nhập lại mật khẩu mới',
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != _passwordController.text) {
                  return 'Mật khẩu không khớp';
                }
                return null;
              },
              colorScheme: colorScheme,
            ),

            SizedBox(height: AppSpacing.md.h),

            // Password Requirements
            _buildPasswordRequirements(colorScheme, textTheme),

            SizedBox(height: AppSpacing.xl.h),

            // Submit button
            ButtonPrimary(
              title: 'Đặt lại mật khẩu',
              variant: ButtonVariant.primarySolid,
              size: ButtonSize.large,
              fullWidth: true,
              loading: widget.isLoading,
              disabled: widget.isLoading,
              onPressed: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: !widget.isLoading,
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
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: colorScheme.outline.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
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
    );
  }

  Widget _buildPasswordRequirements(
      ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yêu cầu mật khẩu:',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          _buildRequirementItem('Ít nhất 6 ký tự', colorScheme, textTheme),
          _buildRequirementItem('Chữ hoa (A-Z)', colorScheme, textTheme),
          _buildRequirementItem('Chữ thường (a-z)', colorScheme, textTheme),
          _buildRequirementItem('Chữ số (0-9)', colorScheme, textTheme),
          _buildRequirementItem(
              'Ký tự đặc biệt (!@#\$%^&*)', colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(
      String text, ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16.sp,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          SizedBox(width: AppSpacing.xs),
          Expanded(child: Text(text, style: textTheme.bodySmall)),
        ],
      ),
    );
  }
}

