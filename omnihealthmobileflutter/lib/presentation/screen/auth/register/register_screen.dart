import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
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

/// Register screen
/// Allows users to create a new account with information:
/// - Email (required)
/// - Password (required)
/// - Full name (required)
/// - Birthday (optional)
/// - Gender (optional)
/// - Role (optional)
/// - Profile image (optional)
///
/// Users must agree to privacy policy and terms of service
/// before they can register
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  @override
  void initState() {
    super.initState();
    // Load roles when screen initializes
    _loadRoles();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  /// Load roles list from API
  void _loadRoles() {
    context.read<RegisterCubit>().loadRoles();
  }

  /// Validate entire form before submit
  bool _validateForm() {
    bool isValid = true;

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email is required');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Invalid email format');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Password is required');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    // Validate fullname
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

    // Validate policy checkbox
    if (!_isPolicyAccepted) {
      setState(() => _policyError = 'You must agree to the policy and terms');
      isValid = false;
    } else {
      setState(() => _policyError = null);
    }

    return isValid;
  }

  /// Check if email is valid
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Handle registration
  void _handleRegister() {
    if (!_validateForm()) {
      _showErrorSnackBar('Please check your information');
      return;
    }

    // Format birthday if exists
    String? birthdayStr;
    if (_selectedBirthday != null) {
      birthdayStr = _selectedBirthday!.toIso8601String();
    }

    // Call cubit to register
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

  /// Show privacy policy PDF
  void _showPrivacyPolicy() {
    // TODO: Implement PDF viewer
    _showInfoDialog('Privacy Policy', 'PDF viewer feature will be updated');
  }

  /// Show terms of service PDF
  void _showTermsOfService() {
    // TODO: Implement PDF viewer
    _showInfoDialog('Terms of Service', 'PDF viewer feature will be updated');
  }

  /// Navigate back to login page
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Navigate to Home after successful registration
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info dialog
  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
          ),
        ),
        content: Text(
          message,
          style: AppTypography.bodyRegularStyle(
            fontSize: AppTypography.fontSizeBase.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            _showSuccessSnackBar('Registration successful!');
            // Navigate to home after 500ms
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
                vertical: AppSpacing.md.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: isLoading ? null : _navigateToLogin,
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md.r),
                          border: Border.all(
                            color: AppColors.gray200,
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl.h),

                  // Header section
                  Text(
                    'Create Account',
                    style: AppTypography.h1.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'Fill in your information to get started',
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl.h),

                  // Form section
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
                  SizedBox(height: AppSpacing.md.h),

                  // Footer - Login link
                  RegisterFooter(
                    onLoginTap: _navigateToLogin,
                    disabled: isLoading,
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
