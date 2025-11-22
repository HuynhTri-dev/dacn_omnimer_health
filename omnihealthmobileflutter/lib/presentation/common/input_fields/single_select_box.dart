import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/validation/field_validator.dart';

enum SelectVariant { primary, secondary }

class SelectOption<T> {
  final String label;
  final T value;

  const SelectOption({required this.label, required this.value});
}

class SingleSelectBox<T> extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final T? value;
  final List<SelectOption<T>> options;
  final ValueChanged<T> onChanged;
  final bool disabled;
  final String? error;
  final String? helperText;
  final SelectVariant variant;
  final List<FieldValidator<T>> validators;
  final Widget? leftIcon;
  final bool searchable;
  final double maxHeight;

  const SingleSelectBox({
    Key? key,
    this.label,
    this.placeholder = 'Chọn một giá trị',
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
  State<SingleSelectBox<T>> createState() => _SingleSelectBoxState<T>();
}

class _SingleSelectBoxState<T> extends State<SingleSelectBox<T>> {
  String? _internalError;
  final TextEditingController _searchController = TextEditingController();

  Color _getBorderColor(bool isOpen) {
    if (widget.disabled) return AppColors.gray300;
    if (widget.error != null || _internalError != null) return AppColors.error;

    if (widget.variant == SelectVariant.secondary) {
      return (isOpen || widget.value != null)
          ? AppColors.gray600
          : AppColors.gray400;
    }

    return (isOpen || widget.value != null)
        ? AppColors.secondary
        : AppColors.primary;
  }

  void _validate(T? value) {
    final error = ValidationRunner.validate(value, widget.validators);
    setState(() {
      _internalError = error;
    });
  }

  void _handleChange(T? value) {
    if (value != null) {
      _validate(value);
      widget.onChanged(value);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;
    // final selectedOption = widget.options.firstWhere(
    //   (opt) => opt.value == widget.value,
    //   orElse: () => SelectOption(label: '', value: widget.value as T),
    // );

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
        DropdownButtonHideUnderline(
          child: DropdownButton2<T>(
            isExpanded: true,
            hint: Row(
              children: [
                if (widget.leftIcon != null) ...[
                  widget.leftIcon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    widget.placeholder!,
                    style: AppTypography.bodyRegularStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            value: widget.value,
            items: widget.options
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item.value,
                    child: Text(
                      item.label,
                      style: AppTypography.bodyRegularStyle(
                        fontSize: AppTypography.fontSizeBase.sp,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: widget.disabled ? null : _handleChange,
            buttonStyleData: ButtonStyleData(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: _getBorderColor(false), width: 1.5),
                borderRadius: BorderRadius.circular(AppRadius.md.r),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: _ChevronDownIcon(),
              iconSize: 18,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: widget.maxHeight,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg.r),
              ),
              offset: const Offset(0, -4),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              selectedMenuItemBuilder: (context, child) {
                return Container(
                  color: AppColors.secondary,
                  child: DefaultTextStyle(
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeBase.sp,
                      color: AppColors.white,
                    ),
                    child: child,
                  ),
                );
              },
            ),
            dropdownSearchData: widget.searchable
                ? DropdownSearchData<T>(
                    searchController: _searchController,
                    searchInnerWidgetHeight: 50,
                    searchInnerWidget: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm...',
                          hintStyle: AppTypography.bodyRegularStyle(
                            fontSize: AppTypography.fontSizeBase.sp,
                            color: AppColors.textMuted,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm.r),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                      ),
                    ),
                    searchMatchFn: (item, searchValue) {
                      return widget.options
                          .firstWhere((opt) => opt.value == item.value)
                          .label
                          .toLowerCase()
                          .contains(searchValue.toLowerCase());
                    },
                  )
                : null,
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

class _ChevronDownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.keyboard_arrow_down,
      color: AppColors.textSecondary,
      size: 24,
    );
  }
}
