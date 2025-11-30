import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_cubit.dart';

/// Step 1: Enter email to receive reset code
class EnterEmailStep extends StatefulWidget {
  final bool isLoading;
  final bool fromAuthenticated;

  const EnterEmailStep({
    Key? key,
    required this.isLoading,
    this.fromAuthenticated = false,
  }) : super(key: key);

  @override
  State<EnterEmailStep> createState() => _EnterEmailStepState();
}

class _EnterEmailStepState extends State<EnterEmailStep> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<ForgotPasswordCubit>()
          .requestPasswordReset(_emailController.text.trim());
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.xl.h),

            // Icon
            Center(
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 48.sp,
                  color: colorScheme.primary,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Title
            Center(
              child: Text(
                'Nhập email của bạn',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.sm.h),

            // Description
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                child: Text(
                  'Chúng tôi sẽ gửi mã xác thực 6 số đến email của bạn để đặt lại mật khẩu.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Email Input
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              placeholder: 'your_email@gmail.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              leftIcon: Icon(
                Icons.email_outlined,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              validators: [
                FieldValidators.required(fieldName: 'Email'),
                FieldValidators.email(fieldName: 'Email'),
              ],
              enabled: !widget.isLoading,
              onSubmitted: (_) => _handleSubmit(),
            ),

            SizedBox(height: AppSpacing.md.h),

            // Info card
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20.sp),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Mã xác thực sẽ hết hạn sau 10 phút',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl.h),

            // Submit button
            ButtonPrimary(
              title: 'Gửi mã xác thực',
              variant: ButtonVariant.primarySolid,
              size: ButtonSize.large,
              fullWidth: true,
              loading: widget.isLoading,
              disabled: widget.isLoading,
              onPressed: _handleSubmit,
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Back to login - only show when not from authenticated screen
            if (!widget.fromAuthenticated)
              Center(
                child: TextButton.icon(
                  onPressed: widget.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    size: 18.sp,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    'Quay lại đăng nhập',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

