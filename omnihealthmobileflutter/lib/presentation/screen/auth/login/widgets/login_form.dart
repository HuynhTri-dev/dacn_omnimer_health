import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_icon.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          backgroundColor: AppColors.error,
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg.w,
        vertical: AppSpacing.xl.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            placeholder: 'your_email@gmail.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            leftIcon: Icon(
              Icons.email_outlined,
              color: AppColors.primary,
              size: 20.sp,
            ),
            validators: [
              FieldValidators.required(fieldName: 'Email'),
              FieldValidators.email(fieldName: 'Email'),
            ],
            enabled: !widget.isLoading,
            onSubmitted: (_) => _passwordFocusNode.requestFocus(),
          ),
          SizedBox(height: AppSpacing.md.h),
          CustomTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            label: 'Password',
            placeholder: 'Password',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            leftIcon: Icon(
              Icons.lock_outline,
              color: AppColors.primary,
              size: 20.sp,
            ),
            rightIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.gray600,
                size: 20.sp,
              ),
            ),
            validators: [FieldValidators.required(fieldName: 'Password')],
            enabled: !widget.isLoading,
            onSubmitted: (_) => _handleLogin(context),
          ),
          SizedBox(height: AppSpacing.sm.h),
          _buildRememberAndForgot(),
          SizedBox(height: AppSpacing.xl.h),
          ButtonPrimary(
            title: 'Sign In',
            variant: ButtonVariant.primarySolid,
            size: ButtonSize.large,
            fullWidth: true,
            loading: widget.isLoading,
            disabled: widget.isLoading,
            onPressed: () => _handleLogin(context),
          ),
          SizedBox(height: AppSpacing.lg.h),
          ButtonIcon(
            title: 'Google',
            icon: const FaIcon(
              FontAwesomeIcons.google,
              size: 20,
              color: Colors.red,
            ),
            variant: ButtonIconVariant.secondaryOutline,
            size: ButtonIconSize.large,
            fullWidth: false,
            disabled: widget.isLoading,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Google Sign In chưa được triển khai'),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.xxl.h),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildRememberAndForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Checkbox(
                value: _rememberPassword,
                onChanged: widget.isLoading
                    ? null
                    : (value) {
                        setState(() => _rememberPassword = value ?? false);
                      },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.xs.w),
            Text(
              'Nhớ Password',
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeSm.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: widget.isLoading
              ? null
              : () =>
                    Navigator.pushReplacementNamed(context, '/forgot-password'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forget password',
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have account",
          style: AppTypography.bodyRegularStyle(
            fontSize: AppTypography.fontSizeSm,
            color: AppColors.textSecondary,
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
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
