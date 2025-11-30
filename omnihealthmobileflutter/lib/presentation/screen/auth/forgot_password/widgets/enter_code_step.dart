import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_cubit.dart';

/// Step 2: Enter 6-digit verification code
class EnterCodeStep extends StatefulWidget {
  final bool isLoading;
  final String? email;

  const EnterCodeStep({
    Key? key,
    required this.isLoading,
    this.email,
  }) : super(key: key);

  @override
  State<EnterCodeStep> createState() => _EnterCodeStepState();
}

class _EnterCodeStepState extends State<EnterCodeStep> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _resendTimer;
  int _resendCountdown = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  void _handleResend() {
    context.read<ForgotPasswordCubit>().resendResetCode();
    _startResendTimer();
    // Clear existing code
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _handleCodeInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Check if all fields are filled
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _handleSubmit();
    }
  }

  void _handleSubmit() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      context.read<ForgotPasswordCubit>().verifyResetCode(code);
    }
  }

  String _getMaskedEmail() {
    if (widget.email == null || widget.email!.isEmpty) return '';
    final parts = widget.email!.split('@');
    if (parts.length != 2) return widget.email!;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return widget.email!;
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
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
              Icons.mark_email_read_outlined,
              size: 48.sp,
              color: colorScheme.primary,
            ),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // Title
          Text(
            'Kiểm tra email của bạn',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
            child: Text(
              'Chúng tôi đã gửi mã 6 số đến\n${_getMaskedEmail()}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // OTP Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (index) => _buildOtpField(index, colorScheme),
            ),
          ),

          SizedBox(height: AppSpacing.xl.h),

          // Verify button
          ButtonPrimary(
            title: 'Xác thực',
            variant: ButtonVariant.primarySolid,
            size: ButtonSize.large,
            fullWidth: true,
            loading: widget.isLoading,
            disabled: widget.isLoading,
            onPressed: _handleSubmit,
          ),

          SizedBox(height: AppSpacing.lg.h),

          // Resend code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Không nhận được mã? ',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              TextButton(
                onPressed: _canResend && !widget.isLoading ? _handleResend : null,
                child: Text(
                  _canResend ? 'Gửi lại' : 'Gửi lại (${_resendCountdown}s)',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _canResend
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md.h),

          // Info card
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.orange, size: 20.sp),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Mã xác thực sẽ hết hạn sau 10 phút. Kiểm tra cả thư mục spam.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index, ColorScheme colorScheme) {
    return SizedBox(
      width: 48.w,
      height: 56.h,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !widget.isLoading,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          filled: true,
          fillColor: colorScheme.surface,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) => _handleCodeInput(value, index),
      ),
    );
  }
}

