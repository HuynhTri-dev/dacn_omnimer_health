import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';

enum ButtonVariant {
  primarySolid,
  secondarySolid,
  dangerSolid,
  primaryOutline,
  secondaryOutline,
  dangerOutline,
}

enum ButtonSize { small, medium, large }

class ButtonPrimary extends StatefulWidget {
  final ButtonVariant variant;
  final String title;
  final bool disabled;
  final bool loading;
  final VoidCallback? onPressed;
  final double? fontSize;
  final FontWeight fontWeight;
  final EdgeInsetsGeometry? padding;
  final ButtonSize size;
  final bool fullWidth;

  const ButtonPrimary({
    Key? key,
    this.variant = ButtonVariant.primarySolid,
    required this.title,
    this.disabled = false,
    this.loading = false,
    this.onPressed,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.padding,
    this.size = ButtonSize.medium,
    this.fullWidth = false,
  }) : super(key: key);

  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  bool _isPressed = false;

  bool get _isSolid => widget.variant.name.contains('Solid');
  bool get _isOutline => widget.variant.name.contains('Outline');

  // Lấy size theo preset với ScreenUtil
  Map<String, double> _getSizeConfig() {
    switch (widget.size) {
      case ButtonSize.small:
        return {'fontSize': 14.0, 'paddingH': 10.0, 'paddingV': 6.0};
      case ButtonSize.large:
        return {'fontSize': 20.0, 'paddingH': 16.0, 'paddingV': 12.0};
      case ButtonSize.medium:
      default:
        return {'fontSize': 16.0, 'paddingH': 12.0, 'paddingV': 8.0};
    }
  }

  Color _getBackgroundColor() {
    if (widget.disabled || widget.loading) {
      return AppColors.gray400;
    }

    if (!_isSolid) {
      return Colors.transparent;
    }

    if (_isPressed) {
      switch (widget.variant) {
        case ButtonVariant.primarySolid:
          return AppColors.secondary;
        case ButtonVariant.secondarySolid:
          return AppColors.gray800;
        case ButtonVariant.dangerSolid:
          return AppColors.dangerHover;
        default:
          return AppColors.primary;
      }
    }

    switch (widget.variant) {
      case ButtonVariant.primarySolid:
        return AppColors.primary;
      case ButtonVariant.secondarySolid:
        return AppColors.gray600;
      case ButtonVariant.dangerSolid:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  Color _getBorderColor() {
    if (widget.disabled || widget.loading) {
      return AppColors.gray400;
    }

    if (!_isOutline) return Colors.transparent;

    if (_isPressed) {
      switch (widget.variant) {
        case ButtonVariant.primaryOutline:
          return AppColors.secondary;
        case ButtonVariant.secondaryOutline:
          return AppColors.gray800;
        case ButtonVariant.dangerOutline:
          return AppColors.dangerHover;
        default:
          return AppColors.primary;
      }
    }

    switch (widget.variant) {
      case ButtonVariant.primaryOutline:
        return AppColors.primary;
      case ButtonVariant.secondaryOutline:
        return AppColors.gray600;
      case ButtonVariant.dangerOutline:
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  Color _getTextColor() {
    if (widget.disabled || widget.loading) {
      return AppColors.textMuted;
    }

    if (_isOutline) {
      if (_isPressed) {
        switch (widget.variant) {
          case ButtonVariant.primaryOutline:
            return AppColors.secondary;
          case ButtonVariant.secondaryOutline:
            return AppColors.gray800;
          case ButtonVariant.dangerOutline:
            return AppColors.dangerHover;
          default:
            return AppColors.primary;
        }
      }

      switch (widget.variant) {
        case ButtonVariant.primaryOutline:
          return AppColors.primary;
        case ButtonVariant.secondaryOutline:
          return AppColors.gray600;
        case ButtonVariant.dangerOutline:
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
    final paddingH = sizeConfig['paddingH']!;
    final paddingV = sizeConfig['paddingV']!;

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
                      width: (fontSize * 1.25).w,
                      height: (fontSize * 1.25).h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  : Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: fontSize.sp,
                        fontFamily: _getFontFamily(),
                        fontWeight: widget.fontWeight,
                      ),
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
