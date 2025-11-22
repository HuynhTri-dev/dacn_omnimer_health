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

class _RadioFieldState<T> extends State<RadioField<T>> {
  String? _internalError;

  Color _getBorderColor(bool isSelected) {
    if (widget.disabled) return AppColors.gray300;

    if (widget.variant == RadioVariant.secondary) {
      return isSelected ? AppColors.gray600 : AppColors.gray400;
    }

    return isSelected ? AppColors.secondary : AppColors.primary;
  }

  Color _getCircleBorderColor(bool isSelected) {
    if (widget.disabled) return AppColors.gray400;

    if (widget.variant == RadioVariant.secondary) {
      return isSelected ? AppColors.gray600 : AppColors.gray400;
    }

    return isSelected ? AppColors.secondary : AppColors.primary;
  }

  Color _getCircleInnerColor() {
    if (widget.variant == RadioVariant.secondary) {
      return AppColors.gray600;
    }
    return AppColors.secondary;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeSm.sp,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildRadioOption(option),
                      ),
                    )
                    .toList(),
              ),
        if (displayError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            displayError,
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeXs.sp,
              color: AppColors.error,
            ),
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.helperText!,
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeXs.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRadioOption(RadioOption<T> option) {
    final isSelected = option.value == widget.value;

    return InkWell(
      onTap: widget.disabled ? null : () => _handleSelect(option.value),
      borderRadius: BorderRadius.circular(AppRadius.sm.r),
      child: Container(
        padding: AppSpacing.paddingSm.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: _getBorderColor(isSelected), width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
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
            const SizedBox(width: AppSpacing.sm),
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
