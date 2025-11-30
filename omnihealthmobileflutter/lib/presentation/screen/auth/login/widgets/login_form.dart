import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';

class LoginForm extends StatefulWidget {
  final bool isLoading;
  const LoginForm({Key? key, required this.isLoading}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _rememberPassword = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      return;
    }

    context.read<LoginCubit>().login(
      email: email,
      password: password,
      rememberPassword: _rememberPassword,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
      padding: EdgeInsets.all(AppSpacing.xl.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome text
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: AppSpacing.sm.w),
              Text(
                'Welcome Back!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: AppTypography.fontSizeLg.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs.h),
          Padding(
            padding: EdgeInsets.only(left: (4.w + AppSpacing.sm.w)),
            child: Text(
              'Sign in to continue your wellness journey',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.fontSizeXs.sp,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          // Email field
          CustomTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            placeholder: 'your_email@gmail.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            leftIcon: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            validators: [
              FieldValidators.required(fieldName: 'Email'),
              FieldValidators.email(fieldName: 'Email'),
            ],
            enabled: !widget.isLoading,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          SizedBox(height: AppSpacing.lg.h),
          // Password field
          CustomTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            placeholder: 'Enter your password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            leftIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            rightIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.hintColor,
                size: 20.sp,
              ),
            ),
            validators: [FieldValidators.required(fieldName: 'Password')],
            enabled: !widget.isLoading,
            onSubmitted: (_) => _handleLogin(context),
          ),
          SizedBox(height: AppSpacing.md.h),
          _buildRememberAndForgot(),
          SizedBox(height: AppSpacing.xl.h),
          // Sign in button
          ButtonPrimary(
            title: 'Sign In',
            variant: ButtonVariant.primarySolid,
            size: ButtonSize.large,
            fullWidth: true,
            loading: widget.isLoading,
            disabled: widget.isLoading,
            onPressed: () => _handleLogin(context),
          ),
          SizedBox(height: AppSpacing.xl.h),
          // Divider with text
          Row(
            children: [
              Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                child: Text(
                  'OR',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs.sp,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: theme.dividerColor, thickness: 1)),
            ],
          ),
          SizedBox(height: AppSpacing.xl.h),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: widget.isLoading
              ? null
              : () {
                  setState(() => _rememberPassword = !_rememberPassword);
                },
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xs.h,
              horizontal: AppSpacing.xs.w,
            ),
            child: Row(
              children: [
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: _rememberPassword
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: _rememberPassword
                          ? theme.colorScheme.primary
                          : theme.dividerColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: _rememberPassword
                      ? Icon(
                          Icons.check,
                          size: 14.sp,
                          color: theme.colorScheme.onPrimary,
                        )
                      : null,
                ),
                SizedBox(width: AppSpacing.sm.w),
                Text(
                  'Remember me',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs.sp,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: widget.isLoading
              ? null
              : () => Navigator.pushNamed(context, '/forget-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm.w,
              vertical: AppSpacing.xs.h,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot password?',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.fontSizeXs.sp,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_outlined,
            size: 18.sp,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          SizedBox(width: AppSpacing.sm.w),
          Text(
            "Don't have an account?",
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: AppTypography.fontSizeXs.sp,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(width: AppSpacing.xs.w),
          TextButton(
            onPressed: widget.isLoading
                ? null
                : () => Navigator.pushReplacementNamed(context, '/register'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Register Now!',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.fontSizeXs.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
