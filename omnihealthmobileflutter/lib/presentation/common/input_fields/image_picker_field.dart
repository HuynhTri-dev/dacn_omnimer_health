import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum ImagePickerVariant { primary, secondary }

/// Widget cho phép người dùng chọn ảnh từ camera hoặc thư viện
/// Hiển thị preview ảnh đã chọn và cho phép xóa/thay đổi ảnh
class ImagePickerField extends StatefulWidget {
  final String? label;
  final File? value;
  final ValueChanged<File?> onChanged;
  final bool disabled;
  final String? error;
  final String? helperText;
  final ImagePickerVariant variant;
  final List<FieldValidator<File>> validators;
  final double? imageHeight;
  final double? imageWidth;
  final bool required;

  const ImagePickerField({
    Key? key,
    this.label,
    this.value,
    required this.onChanged,
    this.disabled = false,
    this.error,
    this.helperText,
    this.variant = ImagePickerVariant.primary,
    this.validators = const [],
    this.imageHeight,
    this.imageWidth,
    this.required = false,
  }) : super(key: key);

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  String? _internalError;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (!_isFocused) _validateOnBlur();
  }

  void _validateOnBlur() {
    _validate(widget.value);
  }

  Color _getBorderColor() {
    final theme = Theme.of(context);
    if (widget.disabled) return theme.disabledColor;
    if (_internalError != null || widget.error != null)
      return theme.colorScheme.error;
    if (_isFocused) return theme.primaryColor;
    return theme.dividerColor;
  }

  void _validate(File? value) {
    final error = ValidationRunner.validate(value, widget.validators);
    setState(() {
      _internalError = error;
    });
  }

  /// Hiển thị bottom sheet để chọn nguồn ảnh (Camera hoặc Thư viện)
  Future<void> _showImageSourceOptions() async {
    if (widget.disabled) return;
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg.r),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.md.h),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                // Title
                Text(
                  'Chọn nguồn ảnh',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.fontSizeLg.sp,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                // Camera option
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Chụp ảnh',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: AppSpacing.sm.h),
                // Gallery option
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Chọn từ thư viện',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: AppSpacing.md.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị từng option trong bottom sheet
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md.r),
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.md.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm.r),
              ),
              child: Icon(icon, color: theme.primaryColor, size: 24.sp),
            ),
            SizedBox(width: AppSpacing.md.w),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: AppTypography.fontSizeBase.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Chọn ảnh từ nguồn đã chọn (camera/gallery)
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        _validate(file);
        widget.onChanged(file);
      }
    } catch (e) {
      setState(() {
        _internalError = 'Có lỗi khi chọn ảnh';
      });
    }
  }

  /// Xóa ảnh đã chọn
  void _removeImage() {
    if (widget.disabled) return;
    _validate(null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTypography.fontSizeSm.sp,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              if (widget.required)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
        ],

        // Image preview or upload button - CENTERED
        Center(
          child: widget.value != null
              ? _buildImagePreview()
              : _buildUploadButton(),
        ),

        if (displayError != null) ...[
          SizedBox(height: AppSpacing.xs.h),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 14,
                color: theme.colorScheme.error,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  displayError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: AppTypography.fontSizeXs.sp,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ] else if (widget.helperText != null) ...[
          SizedBox(height: AppSpacing.xs.h),
          Center(
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.fontSizeXs.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Widget hiển thị nút upload khi chưa có ảnh
  Widget _buildUploadButton() {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.disabled ? null : _showImageSourceOptions,
      child: Focus(
        focusNode: _focusNode,
        child: Container(
          height: widget.imageHeight ?? 120.h,
          width: widget.imageWidth ?? 120.w,
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: _getBorderColor(), width: 1.5),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: theme.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget hiển thị ảnh đã chọn với nút xóa và thay đổi
  Widget _buildImagePreview() {
    final theme = Theme.of(context);
    return Focus(
      focusNode: _focusNode,
      child: Container(
        height: widget.imageHeight ?? 120.h,
        width: widget.imageWidth ?? 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _getBorderColor(), width: 1.5),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Image preview
            ClipOval(
              child: Image.file(
                widget.value!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Overlay buttons (Remove & Change)
            if (!widget.disabled)
              Positioned(
                top: 4.h,
                right: 4.w,
                child: Row(
                  children: [
                    // Change button
                    _buildActionButton(
                      icon: Icons.edit,
                      color: theme.primaryColor,
                      onTap: _showImageSourceOptions,
                    ),
                    SizedBox(width: AppSpacing.xs.w),
                    // Remove button
                    _buildActionButton(
                      icon: Icons.close,
                      color: theme.colorScheme.error,
                      onTap: _removeImage,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Widget nút action (Edit/Remove) trên ảnh preview
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm.r),
      child: Container(
        width: 32.w,
        height: 32.h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: theme.colorScheme.onPrimary, size: 18.sp),
      ),
    );
  }
}
