import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/workout_template_form_screen.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 3T-FIT Button
        Expanded(
          child: _ActionButton(
            icon: Icons.psychology_outlined,
            title: '3T-FIT',
            subtitle: 'Suggest your own workout by 3T-FIT Model',
            backgroundColor: Theme.of(context).primaryColor,
            onTap: () {
              RouteConfig.navigateToWorkoutTemplateAI(context);
            },
          ),
        ),

        SizedBox(width: 12.w),

        // Create Button
        Expanded(
          child: _ActionButton(
            icon: Icons.add_circle_outline,
            title: 'Create',
            subtitle: 'Create your own workout with exercise library',
            backgroundColor: Theme.of(context).primaryColor,
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WorkoutTemplateFormScreen(),
                ),
              );

              // Refresh if template was created
              if (result == true && context.mounted) {
                context.read<WorkoutHomeBloc>().add(RefreshWorkoutData());
              }
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.1),
          border: Border.all(
            color: backgroundColor.withOpacity(0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 24.sp),
            ),

            SizedBox(height: 12.h),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: backgroundColor,
              ),
            ),

            SizedBox(height: 4.h),

            // Subtitle
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11.sp,
                height: 1.3,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
