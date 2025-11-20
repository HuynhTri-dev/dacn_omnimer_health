import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
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
          child: _buildSkeleton(),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.gray200,
      highlightColor: AppColors.gray100,
      child: _buildSkeletonContent(),
    );
  }

  Widget _buildSkeletonContent() {
    switch (variant) {
      case SkeletonVariant.card:
        return _buildCard();
      case SkeletonVariant.textField:
        return _buildTextField();
      case SkeletonVariant.circleImage:
        return _buildCircleImage();
      case SkeletonVariant.rectangleImage:
        return _buildRectangleImage();
      case SkeletonVariant.avatar:
        return _buildAvatar();
      case SkeletonVariant.line:
        return _buildLine();
      case SkeletonVariant.button:
        return _buildButton();
      case SkeletonVariant.listItem:
        return _buildListItem();
      default:
        return Container(
          width: (width ?? double.infinity).w,
          height: (height ?? 100).h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
              (borderRadius ?? AppRadius.md).r,
            ),
          ),
        );
    }
  }

  Widget _buildCard() {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 280).h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular((borderRadius ?? AppRadius.md).r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 150.h,
            color: AppColors.gray200,
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
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Container(
                  width: (width ?? 300).w * 0.9,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.md.h),
                Container(
                  width: 80.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
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

  Widget _buildTextField() {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 48).h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildCircleImage() {
    final size = (width ?? height ?? 80).w;
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildRectangleImage() {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 100).h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular((borderRadius ?? AppRadius.md).r),
      ),
    );
  }

  Widget _buildAvatar() {
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: AppColors.white,
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
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
              ),
              SizedBox(height: AppSpacing.xs.h),
              Container(
                width: double.infinity,
                height: 12.h,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppRadius.sm.r),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLine() {
    return Container(
      width: (width ?? double.infinity).w,
      height: (height ?? 16).h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildButton() {
    return Container(
      width: (width ?? 120).w,
      height: (height ?? 40).h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm.r),
      ),
    );
  }

  Widget _buildListItem() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
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
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppRadius.sm.r),
                  ),
                ),
                SizedBox(height: AppSpacing.xs.h),
                Container(
                  width: (width ?? 300).w * 0.7,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
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
