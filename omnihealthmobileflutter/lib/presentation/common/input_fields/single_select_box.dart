import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final bool required;

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
    this.required = false,
  }) : super(key: key);

  @override
  State<SingleSelectBox<T>> createState() => _SingleSelectBoxState<T>();
}

class _SingleSelectBoxState<T> extends State<SingleSelectBox<T>>
    with SingleTickerProviderStateMixin {
  String? _internalError;
  bool _isFocused = false;
  late FocusNode _focusNode;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
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
  Widget build(BuildContext context) {
    final displayError = widget.error ?? _internalError;
    final theme = Theme.of(context);

    return Focus(
      focusNode: _focusNode,
      child: Column(
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
          Opacity(
            opacity: widget.disabled ? 0.6 : 1.0,
            child: IgnorePointer(
              ignoring: widget.disabled,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<T>(
                  isExpanded: true,
                  hint: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                        child: Text(
                          widget.placeholder!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: AppTypography.fontSizeBase.sp,
                            color: theme.hintColor,
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
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: AppTypography.fontSizeBase.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: widget.disabled ? null : _handleChange,
                  selectedItemBuilder: (context) {
                    return widget.options.map((item) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (widget.leftIcon != null)
                            Container(
                              width: 40.w,
                              height: 40.h,
                              margin: EdgeInsets.only(right: AppSpacing.sm.w),
                              decoration: BoxDecoration(
                                color: theme.scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm.r,
                                ),
                              ),
                              child: Center(child: widget.leftIcon),
                            ),
                          Expanded(
                            child: Text(
                              item.label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppTypography.fontSizeBase.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 56.h,
                    padding: EdgeInsets.only(
                      left: 1.w,
                      right: AppSpacing.md.w,
                      top: AppSpacing.sm.h,
                      bottom: AppSpacing.sm.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          theme.inputDecorationTheme.fillColor ??
                          theme.cardColor,
                      border: Border.all(
                        color: _getBorderColor(false),
                        width: 1.5,
                      ),
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
                  ),
                  iconStyleData: IconStyleData(
                    icon: Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm.w),
                      child: _ChevronDownIcon(),
                    ),
                    iconSize: 20,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: widget.maxHeight,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.md.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    offset: const Offset(0, -4),
                    scrollbarTheme: ScrollbarThemeData(
                      radius: const Radius.circular(40),
                      thickness: MaterialStateProperty.all(6),
                      thumbVisibility: MaterialStateProperty.all(true),
                    ),
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    height: 48.h,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w),
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.hovered)) {
                        return theme.primaryColor.withOpacity(0.05);
                      }
                      if (states.contains(MaterialState.focused)) {
                        return theme.primaryColor.withOpacity(0.08);
                      }
                      return null;
                    }),
                    selectedMenuItemBuilder: (context, child) {
                      return Container(
                        color: theme.primaryColor.withOpacity(0.1),
                        child: DefaultTextStyle(
                          style: theme.textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: AppTypography.fontSizeBase.sp,
                            color: theme.primaryColor,
                          ),
                          child: child,
                        ),
                      );
                    },
                  ),
                  dropdownSearchData: widget.searchable
                      ? DropdownSearchData<T>(
                          searchController: _searchController,
                          searchInnerWidgetHeight: 60,
                          searchInnerWidget: Container(
                            padding: EdgeInsets.all(AppSpacing.md.w),
                            child: TextField(
                              controller: _searchController,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: AppTypography.fontSizeBase.sp,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Tìm kiếm...',
                                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: AppTypography.fontSizeBase.sp,
                                  color: theme.hintColor,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: theme.hintColor,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: theme.scaffoldBackgroundColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md.r,
                                  ),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md.r,
                                  ),
                                  borderSide: BorderSide(
                                    color: theme.dividerColor,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md.r,
                                  ),
                                  borderSide: BorderSide(
                                    color: theme.primaryColor,
                                    width: 2.0,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md.w,
                                  vertical: AppSpacing.sm.h,
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
      ),
    );
  }
}

class _ChevronDownIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.keyboard_arrow_down,
      color: Theme.of(context).textTheme.bodySmall?.color,
      size: 24,
    );
  }
}
