import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/role_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/date_picker_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/image_picker_field.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';

/// Widget containing the entire registration form
/// Includes fields: email, password, fullname, birthday, gender, role, image
class RegisterForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController fullnameController;
  final DateTime? birthday;
  final GenderEnum? gender;
  final String? selectedRoleId;
  final File? selectedImage;
  final ValueChanged<DateTime> onBirthdayChanged;
  final ValueChanged<GenderEnum> onGenderChanged;
  final ValueChanged<String> onRoleChanged;
  final ValueChanged<File?> onImageChanged;
  final String? emailError;
  final String? passwordError;
  final String? fullnameError;
  final bool isLoading;

  // Parameters for roles
  final List<RoleSelectBoxEntity>? roles;
  final bool isLoadingRoles;
  final String? rolesError;

  const RegisterForm({
    Key? key,
    required this.emailController,
    required this.passwordController,
    required this.fullnameController,
    required this.birthday,
    required this.gender,
    required this.selectedRoleId,
    required this.selectedImage,
    required this.onBirthdayChanged,
    required this.onGenderChanged,
    required this.onRoleChanged,
    required this.onImageChanged,
    this.emailError,
    this.passwordError,
    this.fullnameError,
    this.isLoading = false,
    this.roles,
    this.isLoadingRoles = false,
    this.rolesError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image picker field
        ImagePickerField(
          label: 'Profile Picture',
          value: selectedImage,
          onChanged: onImageChanged,
          disabled: isLoading,
          helperText: 'Choose your profile picture',
          imageHeight: 120.h,
        ),

        SizedBox(height: AppSpacing.lg.h),

        // Email field
        CustomTextField(
          label: 'Email',
          placeholder: 'your_email@gmail.com',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          leftIcon: const Icon(Icons.email_outlined, size: 20),
          enabled: !isLoading,
          error: emailError,
          required: true,
          validators: [
            FieldValidators.required(fieldName: "Email"),
            FieldValidators.email(fieldName: 'Email'),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),

        // Password field
        CustomTextField(
          label: 'Password',
          placeholder: 'Set your password',
          controller: passwordController,
          obscureText: true,
          leftIcon: const Icon(Icons.lock_outline, size: 20),
          enabled: !isLoading,
          error: passwordError,
          required: true,
          validators: [
            FieldValidators.required(fieldName: 'Password'),
            FieldValidators.minLength(6, fieldName: 'Password'),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),

        // Fullname field
        CustomTextField(
          label: 'Full Name',
          placeholder: 'Enter your full name',
          controller: fullnameController,
          leftIcon: const Icon(Icons.person_outline, size: 20),
          enabled: !isLoading,
          error: fullnameError,
          required: true,
          validators: [
            FieldValidators.required(fieldName: 'Full name'),
            FieldValidators.minLength(2, fieldName: 'Full name'),
          ],
        ),
        SizedBox(height: AppSpacing.md.h),

        // Birthday field
        DatePickerField(
          label: 'Birthday',
          placeholder: 'Select your birthday',
          value: birthday,
          onChanged: onBirthdayChanged,
          disabled: isLoading,
          maxDate: DateTime.now(),
          minDate: DateTime(1900),
          leftIcon: const Icon(Icons.cake_outlined, size: 20),
          helperText: 'Optional',
        ),
        SizedBox(height: AppSpacing.md.h),

        // Gender field
        SingleSelectBox<GenderEnum>(
          label: 'Gender',
          placeholder: 'Choose your gender',
          value: gender,
          options: const [
            SelectOption(label: 'Male', value: GenderEnum.male),
            SelectOption(label: 'Female', value: GenderEnum.female),
            SelectOption(label: 'Other', value: GenderEnum.other),
          ],
          onChanged: onGenderChanged,
          disabled: isLoading,
          leftIcon: const Icon(Icons.wc_outlined, size: 20),
          helperText: 'Optional',
        ),
        SizedBox(height: AppSpacing.md.h),

        // Role field - Load from API
        SingleSelectBox<String>(
          label: 'Role',
          placeholder: isLoadingRoles ? 'Loading roles...' : 'Select your role',
          value: selectedRoleId,
          options:
              roles
                  ?.map(
                    (role) =>
                        SelectOption(label: role.displayName, value: role.id),
                  )
                  .toList() ??
              [],
          onChanged: onRoleChanged,
          disabled:
              isLoading || isLoadingRoles || roles == null || roles!.isEmpty,
          leftIcon: const Icon(Icons.badge_outlined, size: 20),
          helperText: rolesError ?? 'Choose a role that fits you',
          error: rolesError,
        ),
      ],
    );
  }
}
