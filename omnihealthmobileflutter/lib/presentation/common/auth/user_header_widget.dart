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
class UserHeaderWidget extends StatelessWidget {
  const UserHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          return Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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

                      SizedBox(height: 4.h),

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
              ],
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
      const SnackBar(content: Text('Profile screen - Coming soon!')),
    );
  }

  void _handleThemeTap(BuildContext context) {
    // TODO: Show theme selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            ListTile(
              leading: const Icon(Icons.light_mode, color: AppColors.primary),
              title: Text(
                'Light Mode',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                ),
              ),
              onTap: () {
                // TODO: Set light theme
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode, color: AppColors.primary),
              title: Text(
                'Dark Mode',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                ),
              ),
              onTap: () {
                // TODO: Set dark theme
                Navigator.pop(context);
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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
      offset: Offset(0, 60.h),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
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
          child: Row(
            children: [
              const Icon(Icons.person, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
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
          child: Row(
            children: [
              const Icon(Icons.palette, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Set Theme',
                style: AppTypography.bodyRegularStyle(
                  fontSize: AppTypography.fontSizeBase.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, color: AppColors.danger),
              SizedBox(width: AppSpacing.sm),
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
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
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
      child: Icon(Icons.person, size: 32.sp, color: AppColors.primary),
    );
  }
}
