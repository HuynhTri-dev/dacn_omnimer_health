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
  }) : super(key: key);

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  String? _internalError;

  Color _getBorderColor() {
    if (widget.disabled) return AppColors.gray300;
    if (widget.error != null || _internalError != null) return AppColors.error;

    if (widget.variant == DatePickerVariant.secondary) {
      return widget.value != null ? AppColors.gray600 : AppColors.gray400;
    }

    return widget.value != null ? AppColors.secondary : AppColors.primary;
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
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeSm.sp,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
        ],
        InkWell(
          onTap: _showPicker,
          borderRadius: BorderRadius.circular(AppRadius.sm.r),
          child: Container(
            padding: AppSpacing.paddingMd.h,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: _getBorderColor(), width: 1.5),
              borderRadius: BorderRadius.circular(AppRadius.sm.r),
            ),
            child: Row(
              children: [
                if (widget.leftIcon != null) ...[
                  widget.leftIcon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
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
                SizedBox(width: AppSpacing.sm.h),
                _CalendarIcon(),
              ],
            ),
          ),
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
