import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
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

class _MultiSelectBoxState<T> extends State<MultiSelectBox<T>>
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

  Color _getBorderColor(bool isOpen) {
    final theme = Theme.of(context);
    if (widget.disabled) return theme.disabledColor;
    if (_internalError != null || widget.error != null)
      return theme.colorScheme.error;
    if (_isFocused || isOpen) return theme.primaryColor;
    return theme.dividerColor;
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
    final theme = Theme.of(context);

    final field = MultiSelectDialogField<T>(
      items: widget.options,
      initialValue: widget.value ?? [],
      title: Text(
        widget.label ?? 'Chọn giá trị',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: AppTypography.fontSizeLg.sp,
        ),
      ),
      selectedColor: theme.primaryColor.withOpacity(0.1),
      checkColor: theme.primaryColor,
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
        border: Border.all(color: _getBorderColor(false), width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.md.r),
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
      buttonIcon: Icon(
        Icons.arrow_drop_down,
        color: theme.iconTheme.color,
        size: 24.sp,
      ),
      buttonText: Text(
        selectedCount == 0
            ? widget.placeholder!
            : selectedCount == 1
            ? widget.options
                  .firstWhere((item) => item.value == widget.value![0])
                  .label
            : '$selectedCount mục đã chọn',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: AppTypography.fontSizeBase.sp,
          color: selectedCount > 0
              ? theme.textTheme.bodyMedium?.color
              : theme.hintColor,
        ),
      ),
      chipDisplay: MultiSelectChipDisplay<T>(
        items:
            widget.value
                ?.map(
                  (value) => MultiSelectItem<T>(
                    value,
                    widget.options
                        .firstWhere((item) => item.value == value)
                        .label,
                  ),
                )
                .toList() ??
            [],
        onTap: (value) {
          final newValues = List<T>.from(widget.value ?? []);
          newValues.remove(value);
          _handleChange(newValues);
        },
        chipColor: theme.primaryColor.withOpacity(0.15),
        textStyle: theme.textTheme.bodySmall?.copyWith(
          fontSize: AppTypography.fontSizeXs.sp,
          color: theme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        icon: Icon(Icons.close, size: 16.sp, color: theme.primaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
          side: BorderSide(
            color: theme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        height: 32.h,
      ),
      searchable: widget.searchable,
      searchHint: 'Tìm kiếm...',
      searchTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: AppTypography.fontSizeBase.sp,
      ),
      onConfirm: _handleChange,
      itemsTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontSize: AppTypography.fontSizeBase.sp,
      ),
      selectedItemsTextStyle: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: AppTypography.fontSizeBase.sp,
        color: theme.primaryColor,
      ),
      confirmText: Text(
        'XÁC NHẬN',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: AppTypography.fontSizeBase.sp,
          color: theme.primaryColor,
        ),
      ),
      cancelText: Text(
        'HỦY',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: AppTypography.fontSizeBase.sp,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
      dialogHeight: widget.maxHeight.h,
      dialogWidth: MediaQuery.of(context).size.width * 0.9,
    );

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
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTypography.fontSizeSm.sp,
                  color: displayError != null
                      ? theme.colorScheme.error
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),

          Opacity(
            opacity: widget.disabled ? 0.6 : 1.0,
            child: IgnorePointer(ignoring: widget.disabled, child: field),
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
      ),
    );
  }
}
