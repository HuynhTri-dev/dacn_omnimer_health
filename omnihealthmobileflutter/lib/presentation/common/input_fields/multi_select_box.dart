import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum SelectVariant { primary, secondary }

class MultiSelectBox<T> extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final List<T>? value;
  final List<MultiSelectItem<T>> options;
  final ValueChanged<List<T>> onChanged;
  final bool disabled;
  final String? error;
  final String? helperText;
  final SelectVariant variant;
  final List<FieldValidator<List<T>>> validators;
  final Widget? leftIcon;
  final bool searchable;
  final double maxHeight;

  const MultiSelectBox({
    Key? key,
    this.label,
    this.placeholder = 'Chọn nhiều giá trị',
    this.value,
    required this.options,
    required this.onChanged,
    this.disabled = false,
    this.error,
    this.helperText,
    this.variant = SelectVariant.primary,
    this.validators = const [],
    this.leftIcon,
    this.searchable = false,
    this.maxHeight = 300,
  }) : super(key: key);

  @override
  State<MultiSelectBox<T>> createState() => _MultiSelectBoxState<T>();
}

class _MultiSelectBoxState<T> extends State<MultiSelectBox<T>> {
  String? _internalError;

  Color _getBorderColor(bool isOpen) {
    if (widget.disabled) return AppColors.gray300;
    if (widget.error != null || _internalError != null) return AppColors.error;

    if (widget.variant == SelectVariant.secondary) {
      return (isOpen || (widget.value?.isNotEmpty ?? false))
          ? AppColors.gray600
          : AppColors.gray400;
    }

    return (isOpen || (widget.value?.isNotEmpty ?? false))
        ? AppColors.secondary
        : AppColors.primary;
  }

  void _validate(List<T>? value) {
    final error = ValidationRunner.validate(value, widget.validators);
    setState(() {
      _internalError = error;
    });
  }

  void _handleChange(List<T>? values) {
    if (values != null) {
      _validate(values);
      widget.onChanged(values);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;
    final selectedCount = widget.value?.length ?? 0;

    final field = MultiSelectDialogField<T>(
      items: widget.options,
      initialValue: widget.value ?? [],
      title: Text(
        widget.label ?? 'Chọn giá trị',
        style: AppTypography.bodyBoldStyle(
          fontSize: AppTypography.fontSizeLg.sp,
        ),
      ),
      selectedColor: widget.variant == SelectVariant.secondary
          ? AppColors.gray600
          : AppColors.primary,
      decoration: BoxDecoration(
        color: widget.disabled ? AppColors.gray100 : AppColors.white,
        border: Border.all(color: _getBorderColor(false), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
      buttonIcon: Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
      buttonText: Text(
        selectedCount == 0
            ? widget.placeholder!
            : selectedCount == 1
            ? widget.options
                  .firstWhere((item) => item.value == widget.value![0])
                  .label
            : '$selectedCount mục đã chọn',
        style: AppTypography.bodyRegularStyle(
          fontSize: AppTypography.fontSizeBase.sp,
          color: selectedCount > 0
              ? AppColors.textPrimary
              : AppColors.textMuted,
        ),
      ),
      chipDisplay: MultiSelectChipDisplay<T>(
        onTap: (value) {
          final newValues = List<T>.from(widget.value ?? []);
          newValues.remove(value);
          _handleChange(newValues);
        },
        chipColor: widget.variant == SelectVariant.secondary
            ? AppColors.gray600
            : AppColors.primary,
        textStyle: AppTypography.bodyRegularStyle(
          fontSize: AppTypography.fontSizeXs.sp,
          color: AppColors.white,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
        ),
        chipWidth: AppSpacing.xs,
      ),
      searchable: widget.searchable,
      searchHint: 'Tìm kiếm...',
      searchTextStyle: AppTypography.bodyRegularStyle(
        fontSize: AppTypography.fontSizeBase.sp,
      ),
      onConfirm: _handleChange,
      itemsTextStyle: AppTypography.bodyRegularStyle(
        fontSize: AppTypography.fontSizeBase.sp,
      ),
      selectedItemsTextStyle: AppTypography.bodyBoldStyle(
        fontSize: AppTypography.fontSizeBase.sp,
        color: widget.variant == SelectVariant.secondary
            ? AppColors.gray600
            : AppColors.primary,
      ),
      confirmText: Text(
        'XÁC NHẬN',
        style: AppTypography.bodyBoldStyle(
          fontSize: AppTypography.fontSizeBase.sp,
          color: widget.variant == SelectVariant.secondary
              ? AppColors.gray600
              : AppColors.primary,
        ),
      ),
      cancelText: Text(
        'HỦY',
        style: AppTypography.bodyBoldStyle(
          fontSize: AppTypography.fontSizeBase.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );

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
          const SizedBox(height: AppSpacing.xs),
        ],

        Opacity(
          opacity: widget.disabled ? 0.6 : 1.0,
          child: IgnorePointer(ignoring: widget.disabled, child: field),
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
}
