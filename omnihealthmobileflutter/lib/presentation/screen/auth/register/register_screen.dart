import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/role_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/policy_checkbox.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/register_foot.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/register_form.dart';

/// Register screen with beautiful design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Text field controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();

  // State variables
  DateTime? _selectedBirthday;
  GenderEnum? _selectedGender;
  String? _selectedRoleId;
  File? _selectedImage;
  bool _isPolicyAccepted = false;
  String? _policyError;

  // Error messages from validation
  String? _emailError;
  String? _passwordError;
  String? _fullnameError;

  // Roles data
  List<RoleSelectBoxEntity>? _roles;
  bool _isLoadingRoles = false;
  String? _rolesError;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadRoles();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadRoles() {
    context.read<RegisterCubit>().loadRoles();
  }

  bool _validateForm() {
    bool isValid = true;

    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    if (_fullnameController.text.trim().isEmpty) {
      setState(() => _fullnameError = 'Full name is required');
      isValid = false;
    } else if (_fullnameController.text.trim().length < 2) {
      setState(
        () => _fullnameError = 'Full name must be at least 2 characters',
      );
      isValid = false;
    } else {
      setState(() => _fullnameError = null);
    }

    if (!_isPolicyAccepted) {
      setState(() => _policyError = 'You must agree to the policy and terms');
      isValid = false;
    } else {
      setState(() => _policyError = null);
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _handleRegister() {
    if (!_validateForm()) {
      _showErrorSnackBar('Please check your information');
      return;
    }

    String? birthdayStr;
    if (_selectedBirthday != null) {
      birthdayStr = _selectedBirthday!.toIso8601String();
    }

    context.read<RegisterCubit>().register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullname: _fullnameController.text.trim(),
      birthday: birthdayStr,
      gender: _selectedGender,
      roleIds: _selectedRoleId != null ? [_selectedRoleId!] : null,
      image: _selectedImage,
    );
  }

  void _showPrivacyPolicy() {
    _showInfoDialog('Privacy Policy', 'PDF viewer feature will be updated');
  }

  void _showTermsOfService() {
    _showInfoDialog('Terms of Service', 'PDF viewer feature will be updated');
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(AppSpacing.md.w),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(AppSpacing.md.w),
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            _showSuccessSnackBar('Registration successful!');
            Future.delayed(const Duration(milliseconds: 500), _navigateToHome);
          } else if (state is RegisterFailure) {
            _showErrorSnackBar(state.message);
          } else if (state is RolesLoaded) {
            setState(() {
              _roles = state.roles;
              _isLoadingRoles = false;
              _rolesError = null;
            });
          } else if (state is RolesLoading) {
            setState(() {
              _isLoadingRoles = true;
              _rolesError = null;
            });
          } else if (state is RolesLoadFailure) {
            setState(() {
              _isLoadingRoles = false;
              _rolesError = state.message;
            });
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg.w,
                vertical: AppSpacing.lg.h,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Back button and header in same row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: isLoading ? null : _navigateToLogin,
                            child: Container(
                              width: 44.w,
                              height: 44.h,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md.r,
                                ),
                                border: Border.all(
                                  color: theme.dividerColor,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.shadowColor.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: theme.iconTheme.color,
                                size: 20.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.primary.withOpacity(
                                        0.7,
                                      ),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Create Account',
                                    style: theme.textTheme.displayLarge
                                        ?.copyWith(
                                          fontSize:
                                              AppTypography.fontSize2Xl.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs.h),
                                Text(
                                  'Join us and start your wellness journey today',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: AppTypography.fontSizeXs.sp,
                                    color: theme.textTheme.bodyMedium?.color
                                        ?.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xl.h),

                      // Form in card container
                      Container(
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
                          children: [
                            RegisterForm(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              fullnameController: _fullnameController,
                              birthday: _selectedBirthday,
                              gender: _selectedGender,
                              selectedRoleId: _selectedRoleId,
                              selectedImage: _selectedImage,
                              onBirthdayChanged: (date) {
                                setState(() => _selectedBirthday = date);
                              },
                              onGenderChanged: (gender) {
                                setState(() => _selectedGender = gender);
                              },
                              onRoleChanged: (roleId) {
                                setState(() => _selectedRoleId = roleId);
                              },
                              onImageChanged: (image) {
                                setState(() => _selectedImage = image);
                              },
                              emailError: _emailError,
                              passwordError: _passwordError,
                              fullnameError: _fullnameError,
                              isLoading: isLoading,
                              roles: _roles,
                              isLoadingRoles: _isLoadingRoles,
                              rolesError: _rolesError,
                            ),
                            SizedBox(height: AppSpacing.lg.h),

                            // Policy checkbox
                            PolicyCheckbox(
                              isChecked: _isPolicyAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isPolicyAccepted = value;
                                  _policyError = null;
                                });
                              },
                              onPrivacyPolicyTap: _showPrivacyPolicy,
                              onTermsOfServiceTap: _showTermsOfService,
                              errorMessage: _policyError,
                              disabled: isLoading,
                            ),
                            SizedBox(height: AppSpacing.xl.h),

                            // Register button
                            ButtonPrimary(
                              title: 'Sign Up',
                              onPressed: _handleRegister,
                              loading: isLoading,
                              disabled: isLoading,
                              fullWidth: true,
                              size: ButtonSize.large,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),

                      // Footer
                      RegisterFooter(
                        onLoginTap: _navigateToLogin,
                        disabled: isLoading,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
