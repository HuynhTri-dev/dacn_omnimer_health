import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum TextFieldVariant { primary, secondary }

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String? value;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final String? error;
  final String? helperText;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final bool multiline;
  final int? maxLines;
  final int? maxLength;
  final TextFieldVariant variant;
  final bool autoFocus;
  final List<FieldValidator<String>> validators;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool required;

  const CustomTextField({
    Key? key,
    this.label,
    this.placeholder,
    this.value,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.error,
    this.helperText,
    this.leftIcon,
    this.rightIcon,
    this.multiline = false,
    this.maxLines,
    this.maxLength,
    this.variant = TextFieldVariant.primary,
    this.autoFocus = false,
    this.validators = const [],
    this.controller,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.required = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _internalError;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.value);
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
    if (!_isFocused) _validateOnBlur();
  }

  void _handleTextChange() {
    setState(() => _internalError = null);
  }

  void _validateOnBlur() {
    final error = ValidationRunner.validate(
      _controller.text,
      widget.validators,
    );
    setState(() => _internalError = error);
  }

  // Color _getFillColor(BuildContext context) {
  //   if (!_isFocused && widget.enabled) return AppColors.gray300;
  //   if (_isFocused) return AppColors.white;
  //   if (!widget.enabled) return AppColors.gray100;
  //   return AppColors.gray300;
  // }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);
    if (!widget.enabled) return theme.disabledColor;
    if (_internalError != null || widget.error != null)
      return theme.colorScheme.error;
    if (_isFocused) return theme.primaryColor;
    return theme.dividerColor;
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
            child: Row(
              children: [
                Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: AppTypography.fontSizeSm.sp,
                    color: displayError != null
                        ? theme.colorScheme.error
                        : theme.textTheme.bodyMedium?.color,
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
          ),
        Container(
          decoration: BoxDecoration(
            color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            border: Border.all(color: _getBorderColor(context), width: 1.5),
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
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md.w,
            vertical: AppSpacing.sm.h,
          ),
          child: Row(
            crossAxisAlignment: widget.multiline
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (widget.leftIcon != null)
                Container(
                  width: 40.w,
                  height: 40.h,
                  margin: EdgeInsets.only(right: AppSpacing.sm.w),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                  child: Center(child: widget.leftIcon),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.obscureText,
                  enabled: widget.enabled,
                  autofocus: widget.autoFocus,
                  maxLines: widget.multiline ? (widget.maxLines ?? 5) : 1,
                  maxLength: widget.maxLength,
                  inputFormatters: widget.inputFormatters,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: AppTypography.fontSizeBase.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: theme.hintColor,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4.h,
                      horizontal: 0.w,
                    ),
                  ),
                ),
              ),
              if (widget.rightIcon != null)
                Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm.w),
                  child: widget.rightIcon,
                ),
            ],
          ),
        ),
        if (displayError != null)
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.xs.h,
              left: AppSpacing.xs.w,
            ),
            child: Row(
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
          )
        else if (widget.helperText != null)
          Padding(
            padding: EdgeInsets.only(
              top: AppSpacing.xs.h,
              left: AppSpacing.xs.w,
            ),
            child: Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: AppTypography.fontSizeXs.sp,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
      ],
    );
  }
}
