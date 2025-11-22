import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/role_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/policy_checkbox.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/register_foot.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/widgets/register_form.dart';

/// Màn hình đăng ký tài khoản
/// Cho phép người dùng tạo tài khoản mới với các thông tin:
/// - Email (bắt buộc)
/// - Mật khẩu (bắt buộc)
/// - Họ tên (bắt buộc)
/// - Ngày sinh (tùy chọn)
/// - Giới tính (tùy chọn)
/// - Vai trò (tùy chọn)
/// - Ảnh đại diện (tùy chọn)
///
/// Người dùng phải đồng ý với chính sách bảo mật và điều khoản dịch vụ
/// mới có thể thực hiện đăng ký
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers cho các text fields
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

  // Error messages từ validation
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
    // Load roles khi màn hình khởi tạo
    _loadRoles();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    super.dispose();
  }

  /// Load danh sách vai trò từ API
  void _loadRoles() {
    context.read<RegisterCubit>().loadRoles();
  }

  /// Validate toàn bộ form trước khi submit
  bool _validateForm() {
    bool isValid = true;

    // Validate email
    if (_emailController.text.trim().isEmpty) {
      setState(() => _emailError = 'Email không được để trống');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text.trim())) {
      setState(() => _emailError = 'Email không hợp lệ');
      isValid = false;
    } else {
      setState(() => _emailError = null);
    }

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Mật khẩu không được để trống');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Mật khẩu phải có ít nhất 6 ký tự');
      isValid = false;
    } else {
      setState(() => _passwordError = null);
    }

    // Validate fullname
    if (_fullnameController.text.trim().isEmpty) {
      setState(() => _fullnameError = 'Họ tên không được để trống');
      isValid = false;
    } else if (_fullnameController.text.trim().length < 2) {
      setState(() => _fullnameError = 'Họ tên phải có ít nhất 2 ký tự');
      isValid = false;
    } else {
      setState(() => _fullnameError = null);
    }

    // Validate policy checkbox
    if (!_isPolicyAccepted) {
      setState(
        () => _policyError = 'Bạn phải đồng ý với chính sách và điều khoản',
      );
      isValid = false;
    } else {
      setState(() => _policyError = null);
    }

    return isValid;
  }

  /// Kiểm tra email hợp lệ
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Xử lý đăng ký
  void _handleRegister() {
    if (!_validateForm()) {
      _showErrorSnackBar('Vui lòng kiểm tra lại thông tin');
      return;
    }

    // Format birthday nếu có
    String? birthdayStr;
    if (_selectedBirthday != null) {
      birthdayStr = _selectedBirthday!.toIso8601String();
    }

    // Gọi cubit để đăng ký
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

  /// Hiển thị PDF chính sách bảo mật
  void _showPrivacyPolicy() {
    // TODO: Implement PDF viewer
    _showInfoDialog('Chính sách bảo mật', 'Tính năng xem PDF sẽ được cập nhật');
  }

  /// Hiển thị PDF điều khoản dịch vụ
  void _showTermsOfService() {
    // TODO: Implement PDF viewer
    _showInfoDialog('Điều khoản dịch vụ', 'Tính năng xem PDF sẽ được cập nhật');
  }

  /// Quay về trang đăng nhập
  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Chuyển đến trang Home sau khi đăng ký thành công
  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Hiển thị thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị thông báo thành công
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị dialog thông tin
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
              'Đóng',
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
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _navigateToLogin,
        ),
        title: Text(
          'Đăng ký',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            _showSuccessSnackBar('Đăng ký thành công!');
            // Chuyển đến trang home sau 500ms
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
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header text
                  Text(
                    'Tạo tài khoản mới',
                    style: AppTypography.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    'Điền thông tin để bắt đầu hành trình của bạn',
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl.h),

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
                    title: 'Đăng ký',
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
