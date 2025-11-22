import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

enum ButtonIconVariant {
  primarySolid,
  secondarySolid,
  dangerSolid,
  primaryOutline,
  secondaryOutline,
  dangerOutline,
}

enum ButtonIconSize { small, medium, large }

class ButtonIcon extends StatefulWidget {
  final ButtonIconVariant variant;
  final String? title;
  final Widget icon;
  final bool disabled;
  final bool loading;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final ButtonIconSize size;
  final bool fullWidth;

  const ButtonIcon({
    Key? key,
    this.variant = ButtonIconVariant.primarySolid,
    this.title,
    required this.icon,
    this.disabled = false,
    this.loading = false,
    this.onPressed,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.padding,
    this.size = ButtonIconSize.medium,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<ButtonIcon> createState() => _ButtonIconState();
}

class _ButtonIconState extends State<ButtonIcon> {
  bool _isPressed = false;

  bool get _isSolid => widget.variant.name.contains('Solid');
  bool get _isOutline => widget.variant.name.contains('Outline');

  // Size config with increased padding for spacious UI
  Map<String, double> _getSizeConfig() {
    switch (widget.size) {
      case ButtonIconSize.small:
        return {
          'fontSize': 14.0.sp,
          'iconSize': 16.0.sp,
          'paddingH': 14.0.h,
          'paddingV': 8.0.w,
          'spacing': 6.0.h,
        };
      case ButtonIconSize.large:
        return {
          'fontSize': 20.0.sp,
          'iconSize': 24.0.sp,
          'paddingH': 20.0.h,
          'paddingV': 16.0.w,
          'spacing': 10.0.h,
        };
      case ButtonIconSize.medium:
      default:
        return {
          'fontSize': 16.0.sp,
          'iconSize': 20.0.sp,
          'paddingH': 16.0.h,
          'paddingV': 12.0.w,
          'spacing': 8.0.h,
        };
    }
  }

  Color _getBackgroundColor() {
    if (widget.disabled || widget.loading) return AppColors.gray400;
    if (!_isSolid) return Colors.transparent;
    if (_isPressed) {
      switch (widget.variant) {
        case ButtonIconVariant.primarySolid:
          return AppColors.secondary;
        case ButtonIconVariant.secondarySolid:
          return AppColors.gray800;
        case ButtonIconVariant.dangerSolid:
          return AppColors.dangerHover;
        default:
          return AppColors.primary;
      }
    }
    switch (widget.variant) {
      case ButtonIconVariant.primarySolid:
        return AppColors.primary;
      case ButtonIconVariant.secondarySolid:
        return AppColors.gray600;
      case ButtonIconVariant.dangerSolid:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  Color _getBorderColor() {
    if (widget.disabled || widget.loading) return AppColors.gray400;
    if (!_isOutline) return Colors.transparent;
    if (_isPressed) {
      switch (widget.variant) {
        case ButtonIconVariant.primaryOutline:
          return AppColors.secondary;
        case ButtonIconVariant.secondaryOutline:
          return AppColors.gray800;
        case ButtonIconVariant.dangerOutline:
          return AppColors.dangerHover;
        default:
          return AppColors.primary;
      }
    }
    switch (widget.variant) {
      case ButtonIconVariant.primaryOutline:
        return AppColors.primary;
      case ButtonIconVariant.secondaryOutline:
        return AppColors.gray600;
      case ButtonIconVariant.dangerOutline:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    if (widget.disabled || widget.loading) return AppColors.textMuted;
    if (_isOutline) {
      if (_isPressed) {
        switch (widget.variant) {
          case ButtonIconVariant.primaryOutline:
            return AppColors.secondary;
          case ButtonIconVariant.secondaryOutline:
            return AppColors.gray800;
          case ButtonIconVariant.dangerOutline:
            return AppColors.dangerHover;
          default:
            return AppColors.primary;
        }
      }
      switch (widget.variant) {
        case ButtonIconVariant.primaryOutline:
          return AppColors.primary;
        case ButtonIconVariant.secondaryOutline:
          return AppColors.gray600;
        case ButtonIconVariant.dangerOutline:
          return AppColors.danger;
        default:
          return AppColors.primary;
      }
    }
    return AppColors.white;
  }

  String _getFontFamily() {
    return widget.fontWeight == FontWeight.w700
        ? AppTypography.bodyBold
        : AppTypography.bodyRegular;
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _getSizeConfig();
    final fontSize = widget.fontSize ?? sizeConfig['fontSize']!;
    final iconSize = sizeConfig['iconSize']!;
    final paddingH = sizeConfig['paddingH']!;
    final paddingV = sizeConfig['paddingV']!;
    final spacing = sizeConfig['spacing']!;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: Opacity(
        opacity: widget.disabled && !widget.loading ? 0.5 : 1.0,
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(AppRadius.md.r),
          child: InkWell(
            onTap: widget.disabled || widget.loading ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.md.r),
            child: Container(
              padding:
                  widget.padding ??
                  EdgeInsets.symmetric(
                    horizontal: paddingH.w,
                    vertical: paddingV.h,
                  ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md.r),
                border: _isOutline
                    ? Border.all(color: _getBorderColor(), width: 2.w)
                    : null,
              ),
              child: widget.loading
                  ? SizedBox(
                      width: (iconSize * 1.2).w,
                      height: (iconSize * 1.2).h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: widget.fullWidth
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconTheme(
                          data: IconThemeData(
                            color: _getTextColor(),
                            size: iconSize.sp,
                          ),
                          child: widget.icon,
                        ),
                        if (widget.title != null) ...[
                          SizedBox(width: spacing.w),
                          Flexible(
                            child: Text(
                              widget.title!,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: _getTextColor(),
                                fontSize: fontSize.sp,
                                fontFamily: _getFontFamily(),
                                fontWeight: widget.fontWeight,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
