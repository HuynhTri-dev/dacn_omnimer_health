import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';

class InfoAccountAvatar extends StatelessWidget {
  final File? selectedImage;
  final String? currentImageUrl;
  final VoidCallback onPickImage;
  final bool isLoading;

  const InfoAccountAvatar({
    super.key,
    this.selectedImage,
    this.currentImageUrl,
    required this.onPickImage,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: isLoading ? null : onPickImage,
        child: Stack(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gray200,
                border: Border.all(color: AppColors.primary, width: 3.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: selectedImage != null
                    ? DecorationImage(
                        image: FileImage(selectedImage!),
                        fit: BoxFit.cover,
                      )
                    : (currentImageUrl != null && currentImageUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(currentImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child:
                  (selectedImage == null &&
                      (currentImageUrl == null || currentImageUrl!.isEmpty))
                  ? Icon(Icons.person, size: 60.w, color: AppColors.gray500)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2.w),
                ),
                child: Icon(Icons.camera_alt, size: 20.w, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
