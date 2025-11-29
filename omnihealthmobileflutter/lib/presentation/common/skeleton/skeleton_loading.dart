import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:shimmer/shimmer.dart';

enum SkeletonVariant {
  card,
  textField,
  circleImage,
  rectangleImage,
  avatar,
  line,
  button,
  listItem,
}

class SkeletonLoading extends StatelessWidget {
  final SkeletonVariant variant;
  final double? width;
  final double? height;
  final double? borderRadius;
  final int count;

  const SkeletonLoading({
    Key? key,
    required this.variant,
    this.width,
    this.height,
    this.borderRadius,
    this.count = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Padding(
          padding: index > 0
              ? EdgeInsets.only(top: AppSpacing.md.h)
              : EdgeInsets.zero,
          child: _buildSkeleton(context),
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.disabledColor.withOpacity(0.3),
      highlightColor: theme.cardColor,
      child: _buildSkeletonContent(context),
    );
  }

  Widget _buildSkeletonContent(BuildContext context) {
    switch (variant) {
      case SkeletonVariant.card:
        return _buildCard(context);
      case SkeletonVariant.textField:
        return _buildTextField(context);
      case SkeletonVariant.circleImage:
        return _buildCircleImage(context);
      case SkeletonVariant.rectangleImage:
        return _buildRectangleImage(context);
      case SkeletonVariant.avatar:
        return _buildAvatar(context);
      case SkeletonVariant.line:
        return _buildLine(context);
      case SkeletonVariant.button:
        return _buildButton(context);
      case SkeletonVariant.listItem:
        return _buildListItem(context);
      default:
        return Container(
          width: (width ?? double.infinity).w,
          height: (height ?? 100).h,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(
              (borderRadius ?? AppRadius.md).r,
            ),
          ),
        );
    }
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 280).h,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular((borderRadius ?? AppRadius.md).r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150.h,
            color: theme.dividerColor,
          ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: (width ?? 300).w * 0.7,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Container(
                  width: (width ?? 300).w * 0.9,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Container(
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context) {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 48).h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildCircleImage(BuildContext context) {
    final size = (width ?? height ?? 80).w;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRectangleImage(BuildContext context) {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 100).h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular((borderRadius ?? AppRadius.md).r),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: theme.cardColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSpacing.md.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Container(
                width: double.infinity,
                height: 12.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine(BuildContext context) {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 16).h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildButton(BuildContext context) {
    return Container(
      width: (width ?? 120).w,
      height: (height ?? 40).h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Container(
                  width: (width ?? 300).w * 0.7,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
