import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';

/// Header hiển thị thông tin user với dropdown menu
/// Bao gồm: Avatar, Tên, Vai trò và menu Profile/Theme/Logout
/// Layout đã được tối ưu để tránh camera/notch và hiển thị đẹp hơn
class UserHeaderWidget extends StatelessWidget {
  const UserHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          return SafeArea(
            bottom: false,
            child: Container(
              margin: EdgeInsets.only(
                top: AppSpacing.xs,
                left: AppSpacing.md,
                right: AppSpacing.md,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadius.radiusLg,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar với dropdown menu
                  _AvatarWithMenu(
                    imageUrl: state.user.imageUrl,
                    onProfileTap: () => _handleProfileTap(context),
                    onThemeTap: () => _handleThemeTap(context),
                    onLogoutTap: () => _handleLogoutTap(context),
                  ),

                  SizedBox(width: AppSpacing.md),

                  // Thông tin user
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tên
                        Text(
                          state.user.fullname,
                          style: AppTypography.bodyBoldStyle(
                            fontSize: AppTypography.fontSizeBase.sp,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 2.h),

                        // Vai trò
                        Text(
                          state.user.roleName.isNotEmpty
                              ? state.user.roleName.join(', ')
                              : 'No Role',
                          style: AppTypography.bodyRegularStyle(
                            fontSize: AppTypography.fontSizeSm.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: AppSpacing.sm),

                  // Menu icon indicator
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.sp,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          );
        }

        // Trường hợp chưa authenticated hoặc đang loading
        return const SizedBox.shrink();
      },
    );
  }

  void _handleProfileTap(BuildContext context) {
    // TODO: Navigate to profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile screen - Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        margin: AppSpacing.paddingMd,
      ),
    );
  }

  void _handleThemeTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Text(
          'Change Theme',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Light Mode',
              onTap: () {
                // TODO: Set light theme
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Light theme selected'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    margin: AppSpacing.paddingMd,
                  ),
                );
              },
            ),
            SizedBox(height: AppSpacing.xs),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              onTap: () {
                // TODO: Set dark theme
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Dark theme selected'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMd,
                    ),
                    margin: AppSpacing.paddingMd,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogoutTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        title: Text(
          'Logout',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTypography.bodyRegularStyle(
            fontSize: AppTypography.fontSizeBase.sp,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            child: Text(
              'Cancel',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthenticationBloc>().add(AuthenticationLoggedOut());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
            ),
            child: Text(
              'Logout',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget theme option cho dialog
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ThemeOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusMd,
      child: Container(
        padding: AppSpacing.paddingSm,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24.sp),
            SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget avatar với popup menu
class _AvatarWithMenu extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onProfileTap;
  final VoidCallback onThemeTap;
  final VoidCallback onLogoutTap;

  const _AvatarWithMenu({
    Key? key,
    this.imageUrl,
    required this.onProfileTap,
    required this.onThemeTap,
    required this.onLogoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 56.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'profile':
            onProfileTap();
            break;
          case 'theme':
            onThemeTap();
            break;
          case 'logout':
            onLogoutTap();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Profile',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'theme',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.palette_outlined,
                  color: AppColors.primary,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Theme',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          height: 1,
          padding: EdgeInsets.zero,
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.textSecondary.withOpacity(0.1),
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.logout_outlined,
                  color: AppColors.danger,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                'Logout',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 48.w,
        height: 48.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _DefaultAvatar();
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _DefaultAvatar();
                  },
                )
              : _DefaultAvatar(),
        ),
      ),
    );
  }
}

/// Avatar mặc định khi không có ảnh
class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.1),
      child: Icon(Icons.person, size: 28.sp, color: AppColors.primary),
    );
  }
}
