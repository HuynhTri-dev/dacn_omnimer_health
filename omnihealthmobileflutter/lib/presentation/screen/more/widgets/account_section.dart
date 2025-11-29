import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/widgets/more_menu_item.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/verify_account/verify_account_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/change_password/change_password_screen.dart';

/// Account section widget for More screen
class AccountSection extends StatefulWidget {
  final VoidCallback onPremiumTap;

  const AccountSection({Key? key, required this.onPremiumTap})
    : super(key: key);

  @override
  State<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends State<AccountSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Menu Item with Dropdown
        MoreMenuItem(
          icon: Icons.person_outline,
          title: 'Profile',
          subtitle: 'Manage personal info',
          onTap: _toggleExpanded,
          trailing: Builder(
            builder: (context) => RotationTransition(
              turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.6),
                size: 24.sp,
              ),
            ),
          ),
        ),

        // Dropdown Menu
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            margin: EdgeInsets.only(
              left: AppSpacing.lg,
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                _buildDropdownItem(
                  icon: Icons.verified_user_outlined,
                  title: 'Verify Account',
                  subtitle: 'Email & authentication methods',
                  onTap: () =>
                      _navigateToScreen(context, const VerifyAccountScreen()),
                ),
                _buildDropdownItem(
                  icon: Icons.info_outline,
                  title: 'Info Account',
                  subtitle: 'Update basic information',
                  onTap: () => RouteConfig.navigateToInfoAccount(context),
                ),
                _buildDropdownItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your password',
                  onTap: () =>
                      _navigateToScreen(context, const ChangePasswordScreen()),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: AppSpacing.sm),

        // Premium Menu Item
        Builder(
          builder: (context) {
            final textTheme = Theme.of(context).textTheme;
            final warningColor = Colors.orange; // Semantic warning color

            return MoreMenuItem(
              icon: Icons.workspace_premium_outlined,
              title: 'Upgrade to Premium',
              subtitle: 'Unlock advanced features',
              iconColor: warningColor,
              backgroundColor: warningColor.withOpacity(0.1),
              onTap: widget.onPremiumTap,
              trailing: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: warningColor,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  'PRO',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: AppRadius.radiusSm,
                  ),
                  child: Icon(icon, color: colorScheme.primary, size: 20.sp),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(subtitle, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: textTheme.bodySmall?.color?.withOpacity(0.6),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
