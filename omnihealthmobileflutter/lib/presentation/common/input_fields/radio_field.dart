import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum RadioVariant { primary, secondary }

class RadioOption<T> {
  final String label;
  final T value;

  const RadioOption({required this.label, required this.value});
}

class RadioField<T> extends StatefulWidget {
  final String? label;
  final T? value;
  final List<RadioOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool disabled;
  final String? error;
  final String? helperText;
  final RadioVariant variant;
  final List<FieldValidator<T>> validators;
  final bool horizontal;

  const RadioField({
    Key? key,
    this.label,
    this.value,
    required this.options,
    required this.onChanged,
    this.disabled = false,
    this.error,
    this.helperText,
    this.variant = RadioVariant.primary,
    this.validators = const [],
    this.horizontal = false,
  }) : super(key: key);

  @override
  State<RadioField<T>> createState() => _RadioFieldState<T>();
}

class _RadioFieldState<T> extends State<RadioField<T>>
    with SingleTickerProviderStateMixin {
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

  Color _getBorderColor(bool isSelected) {
    if (widget.disabled) return AppColors.gray300;
    if (_internalError != null || widget.error != null) return AppColors.error;
    if (isSelected || _isFocused) return AppColors.primary;
    return AppColors.gray200;
  }

  Color _getCircleBorderColor(bool isSelected) {
    if (widget.disabled) return AppColors.gray400;
    return isSelected ? AppColors.primary : AppColors.gray200;
  }

  Color _getCircleInnerColor() {
    return AppColors.primary;
  }

  void _validate(T? value) {
    final error = ValidationRunner.validate(value, widget.validators);
    setState(() {
      _internalError = error;
    });
  }

  void _handleSelect(T value) {
    if (widget.disabled) return;
    _validate(value);
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;

    return Focus(
      focusNode: _focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
              child: Text(
                widget.label!,
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeSm.sp,
                  color: displayError != null
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ),
          widget.horizontal
              ? Row(
                  children: widget.options
                      .asMap()
                      .entries
                      .map(
                        (entry) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: entry.key > 0 ? AppSpacing.sm.h : 0,
                            ),
                            child: _buildRadioOption(entry.value),
                          ),
                        ),
                      )
                      .toList(),
                )
              : Column(
                  children: widget.options
                      .map(
                        (option) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                          child: _buildRadioOption(option),
                        ),
                      )
                      .toList(),
                ),
          if (displayError != null)
            Padding(
              padding: EdgeInsets.only(
                top: AppSpacing.xs.h,
                left: AppSpacing.xs.w,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 14,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      displayError,
                      style: AppTypography.bodyRegularStyle(
                        fontSize: AppTypography.fontSizeXs.sp,
                        color: AppColors.error,
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
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeXs.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadioOption(RadioOption<T> option) {
    final isSelected = option.value == widget.value;

    return GestureDetector(
      onTap: widget.disabled ? null : () => _handleSelect(option.value),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md.w,
          vertical: AppSpacing.sm.h,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: _getBorderColor(isSelected), width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          boxShadow: isSelected || _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getCircleBorderColor(isSelected),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getCircleInnerColor(),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppSpacing.sm.w),
            Expanded(
              child: Text(
                option.label,
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: widget.disabled
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
