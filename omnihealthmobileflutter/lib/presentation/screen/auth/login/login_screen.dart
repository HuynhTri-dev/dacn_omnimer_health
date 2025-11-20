import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_state.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LoginHeader(),
                  Text(
                    'OmniMer Health',
                    style: AppTypography.headingBoldStyle(
                      fontSize: AppTypography.fontSize2Xl.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs.h),
                  Text(
                    'Cảm hứng sống khỏe, mỗi ngày một tốt hơn.',
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeSm.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  LoginForm(isLoading: isLoading),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
