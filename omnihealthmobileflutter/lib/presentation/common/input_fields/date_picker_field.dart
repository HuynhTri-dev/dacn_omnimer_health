import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum DatePickerVariant { primary, secondary }

enum DatePickerMode { date, time, datetime }

typedef ValidationRule = String? Function(DateTime?);

class DatePickerField extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DatePickerMode mode;
  final bool disabled;
  final String? error;
  final String? helperText;
  final DatePickerVariant variant;
  final List<FieldValidator<DateTime>> validators;
  final Widget? leftIcon;
  final String? format;
  final bool required;

  const DatePickerField({
    Key? key,
    this.label,
    this.placeholder = 'Chọn ngày',
    this.value,
    required this.onChanged,
    this.minDate,
    this.maxDate,
    this.mode = DatePickerMode.date,
    this.disabled = false,
    this.error,
    this.helperText,
    this.variant = DatePickerVariant.primary,
    this.validators = const [],
    this.leftIcon,
    this.format,
    this.required = false,
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField>
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
    final error = ValidationRunner.validate(widget.value, widget.validators);
    setState(() => _internalError = error);
  }

  Color _getBorderColor() {
    if (widget.disabled) return AppColors.gray300;
    if (_internalError != null || widget.error != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.gray200;
  }

  String _formatDate(DateTime date) {
    if (widget.format != null) {
      try {
        return DateFormat(widget.format).format(date);
      } catch (e) {
        // Fallback to default format
      }
    }

    switch (widget.mode) {
      case DatePickerMode.date:
        return DateFormat('dd/MM/yyyy').format(date);
      case DatePickerMode.time:
        return DateFormat('HH:mm').format(date);
      case DatePickerMode.datetime:
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  void _validate(DateTime? value) {
    final error = ValidationRunner.validate(value, widget.validators);
    setState(() {
      _internalError = error;
    });
  }

  Future<void> _showPicker() async {
    if (widget.disabled) return;

    DateTime? selectedDate;

    if (widget.mode == DatePickerMode.time) {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: widget.value != null
            ? TimeOfDay.fromDateTime(widget.value!)
            : TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: widget.variant == DatePickerVariant.secondary
                    ? AppColors.gray600
                    : AppColors.secondary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        final now = DateTime.now();
        selectedDate = DateTime(
          now.year,
          now.month,
          now.day,
          picked.hour,
          picked.minute,
        );
      }
    } else {
      selectedDate = await showDatePicker(
        context: context,
        initialDate: widget.value ?? DateTime.now(),
        firstDate: widget.minDate ?? DateTime(1900),
        lastDate: widget.maxDate ?? DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: widget.variant == DatePickerVariant.secondary
                    ? AppColors.gray600
                    : AppColors.secondary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (selectedDate != null && widget.mode == DatePickerMode.datetime) {
        if (!mounted) return;
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: widget.value != null
              ? TimeOfDay.fromDateTime(widget.value!)
              : TimeOfDay.now(),
        );

        if (picked != null) {
          selectedDate = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            picked.hour,
            picked.minute,
          );
        }
      }
    }

    if (selectedDate != null) {
      _validate(selectedDate);
      widget.onChanged(selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;

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
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeSm.sp,
                    color: displayError != null
                        ? AppColors.error
                        : AppColors.textPrimary,
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
        GestureDetector(
          onTap: widget.disabled ? null : _showPicker,
          child: Focus(
            focusNode: _focusNode,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: Border.all(color: _getBorderColor(), width: 1.5),
                boxShadow: _isFocused
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
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: AppSpacing.sm.h,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.leftIcon != null)
                    Container(
                      width: 40.w,
                      height: 40.h,
                      margin: EdgeInsets.only(right: AppSpacing.sm.w),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadius.sm.r),
                      ),
                      child: Center(child: widget.leftIcon),
                    ),
                  Expanded(
                    child: Text(
                      widget.value != null
                          ? _formatDate(widget.value!)
                          : widget.placeholder!,
                      style: AppTypography.bodyRegularStyle(
                        fontSize: AppTypography.fontSizeBase.sp,
                        color: widget.value != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm.w),
                    child: _CalendarIcon(),
                  ),
                ],
              ),
            ),
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
    );
  }
}

class _CalendarIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSecondary, width: 1.5),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_buildDot(), _buildDot()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 2,
      height: 2,
      decoration: const BoxDecoration(
        color: AppColors.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }
}
