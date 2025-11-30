import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/cubits/forgot_password_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/widgets/enter_email_step.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/widgets/enter_code_step.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/widgets/enter_new_password_step.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/widgets/success_step.dart';

/// Forgot Password Screen - Multi-step password recovery
class ForgotPasswordScreen extends StatelessWidget {
  /// If true, user came from authenticated screen (e.g., Change Password)
  /// If false, user came from Login screen
  final bool fromAuthenticated;

  const ForgotPasswordScreen({
    Key? key,
    this.fromAuthenticated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ForgotPasswordCubit>(),
      child: _ForgotPasswordView(fromAuthenticated: fromAuthenticated),
    );
  }
}

class _ForgotPasswordView extends StatefulWidget {
  final bool fromAuthenticated;

  const _ForgotPasswordView({
    Key? key,
    required this.fromAuthenticated,
  }) : super(key: key);

  @override
  State<_ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<_ForgotPasswordView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is ForgotPasswordCodeSent ||
              state is ForgotPasswordCodeResent) {
            _goToPage(1);
          } else if (state is ForgotPasswordCodeVerified) {
            _goToPage(2);
          } else if (state is ForgotPasswordSuccess) {
            _goToPage(3);
          } else if (state is ForgotPasswordError) {
            if (state.requireEmailVerification) {
              _showEmailVerificationDialog(context, state.message);
            } else {
              _showErrorSnackBar(context, state.message);
            }
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.surface,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // App Bar
                  _buildAppBar(context, state),

                  // Progress Indicator
                  if (_currentPage < 3) _buildProgressIndicator(context),

                  // Content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        EnterEmailStep(
                          isLoading: state is ForgotPasswordLoading &&
                              state.step == ForgotPasswordStep.enterEmail,
                          fromAuthenticated: widget.fromAuthenticated,
                        ),
                        EnterCodeStep(
                          isLoading: state is ForgotPasswordLoading &&
                              state.step == ForgotPasswordStep.enterCode,
                          email: context.read<ForgotPasswordCubit>().currentEmail,
                        ),
                        EnterNewPasswordStep(
                          isLoading: state is ForgotPasswordLoading &&
                              state.step == ForgotPasswordStep.enterNewPassword,
                        ),
                        SuccessStep(fromAuthenticated: widget.fromAuthenticated),
                      ],
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

  Widget _buildAppBar(BuildContext context, ForgotPasswordState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md.w,
        vertical: AppSpacing.sm.h,
      ),
      child: Row(
        children: [
          if (_currentPage > 0 && _currentPage < 3)
            IconButton(
              onPressed: () {
                if (_currentPage == 1) {
                  context.read<ForgotPasswordCubit>().goBackToEmail();
                  _goToPage(0);
                } else if (_currentPage == 2) {
                  context.read<ForgotPasswordCubit>().goBackToCode();
                  _goToPage(1);
                }
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: colorScheme.onSurface,
              ),
            )
          else if (_currentPage == 0)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: colorScheme.onSurface,
              ),
            )
          else
            SizedBox(width: 48.w),
          Expanded(
            child: Text(
              _getTitle(),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentPage) {
      case 0:
        return 'Quên mật khẩu';
      case 1:
        return 'Nhập mã xác thực';
      case 2:
        return 'Mật khẩu mới';
      case 3:
        return 'Thành công';
      default:
        return 'Quên mật khẩu';
    }
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl.w,
        vertical: AppSpacing.md.h,
      ),
      child: Row(
        children: [
          _buildProgressDot(0, colorScheme),
          _buildProgressLine(0, colorScheme),
          _buildProgressDot(1, colorScheme),
          _buildProgressLine(1, colorScheme),
          _buildProgressDot(2, colorScheme),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int index, ColorScheme colorScheme) {
    final isActive = _currentPage >= index;
    final isCurrent = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCurrent ? 32.w : 24.w,
      height: isCurrent ? 32.w : 24.w,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isActive
            ? Icon(
                index < _currentPage ? Icons.check : _getStepIcon(index),
                color: colorScheme.onPrimary,
                size: isCurrent ? 18.sp : 14.sp,
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.email_outlined;
      case 1:
        return Icons.pin_outlined;
      case 2:
        return Icons.lock_outline;
      default:
        return Icons.check;
    }
  }

  Widget _buildProgressLine(int index, ColorScheme colorScheme) {
    final isActive = _currentPage > index;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3.h,
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs.w),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
        margin: EdgeInsets.all(AppSpacing.md.w),
      ),
    );
  }

  void _showEmailVerificationDialog(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg.r),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.md.h),
            // Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 40.sp,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            // Title
            Text(
              'Xác thực email',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.md.h),
            // Message
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg.h),
            // Info box
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
                      'Kiểm tra cả thư mục spam nếu không thấy email.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Đã hiểu',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

