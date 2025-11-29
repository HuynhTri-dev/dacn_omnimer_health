import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/auth/user_entity.dart';

import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/cubits/info_account_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/cubits/info_account_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/widgets/info_account_avatar.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/widgets/info_account_form.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/widgets/info_account_read_only.dart';

class InfoAccountScreen extends StatefulWidget {
  const InfoAccountScreen({super.key});

  @override
  State<InfoAccountScreen> createState() => _InfoAccountScreenState();
}

class _InfoAccountScreenState extends State<InfoAccountScreen> {
  final _fullnameController = TextEditingController();
  final _birthdayController = TextEditingController();
  GenderEnum? _selectedGender;
  File? _selectedImage;
  String? _currentImageUrl;
  String? _userId;
  String? _email;
  List<String>? _roles;

  @override
  void dispose() {
    _fullnameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, InfoAccountState state) {
    if (state is InfoAccountLoaded) {
      _updateLocalState(state.user);
    } else if (state is InfoAccountSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message), backgroundColor: Colors.green),
      );
      _updateLocalState(state.user);
      _selectedImage = null; // Reset selected image after upload
    } else if (state is InfoAccountError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _updateLocalState(UserEntity user) {
    setState(() {
      _userId = user.id;
      _fullnameController.text = user.fullname ?? '';
      _birthdayController.text = user.birthday ?? '';
      _selectedGender = user.gender;
      _currentImageUrl = user.imageUrl;
      _email = user.email;
      _roles = user.roleNames;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthdayController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() {
    if (_fullnameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập họ tên")));
      return;
    }

    if (_userId == null) return;

    context.read<InfoAccountCubit>().updateUserInfo(
      id: _userId!,
      fullname: _fullnameController.text,
      birthday: _birthdayController.text,
      gender: _selectedGender,
      image: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account",
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<InfoAccountCubit, InfoAccountState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state is InfoAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InfoAccountError && _userId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ButtonPrimary(
                    title: "Reload",
                    onPressed: () =>
                        context.read<InfoAccountCubit>().loadUserInfo(),
                    size: ButtonSize.small,
                  ),
                ],
              ),
            );
          }

          final isLoading = state is InfoAccountUpdating;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg.w,
              vertical: AppSpacing.xl.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Section
                InfoAccountAvatar(
                  selectedImage: _selectedImage,
                  currentImageUrl: _currentImageUrl,
                  onPickImage: _pickImage,
                  isLoading: isLoading,
                ),
                SizedBox(height: AppSpacing.xxl.h),

                // Read Only Info (Email, Roles)
                InfoAccountReadOnly(email: _email, roles: _roles),
                SizedBox(height: AppSpacing.xl.h),

                // Editable Form
                Container(
                  padding: EdgeInsets.all(AppSpacing.md.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "User info",
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      InfoAccountForm(
                        fullnameController: _fullnameController,
                        birthdayController: _birthdayController,
                        selectedGender: _selectedGender,
                        onGenderChanged: (value) {
                          setState(() => _selectedGender = value);
                        },
                        onSelectDate: () => _selectDate(context),
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxl.h),

                // Submit Button
                ButtonPrimary(
                  title: "Save changes",
                  onPressed: isLoading ? null : _submit,
                  loading: isLoading,
                  fullWidth: true,
                  size: ButtonSize.large,
                ),
                SizedBox(height: AppSpacing.xxl.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
