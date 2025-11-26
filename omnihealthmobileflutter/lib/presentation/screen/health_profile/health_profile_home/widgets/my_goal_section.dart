import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/common/skeleton/skeleton_loading.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/goal_card.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/goal_detail_bottom_sheet.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/goal_empty_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/widgets/goal_section_header.dart';

class MyGoalSection extends StatelessWidget {
  const MyGoalSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalBloc, GoalState>(
      listener: (context, state) {
        if (state is GoalDeleted || state is GoalOperationSuccess) {
          _refreshGoals(context);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          SizedBox(height: AppSpacing.md.h),
          _buildGoalList(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is! AuthenticationAuthenticated) {
          return const SizedBox.shrink();
        }

        return GoalSectionHeader(
          onAddTap: () => _navigateToGoalForm(context, state.user.id),
        );
      },
    );
  }

  Widget _buildGoalList(BuildContext context) {
    return BlocBuilder<HealthProfileBloc, HealthProfileState>(
      builder: (context, state) {
        if (state is HealthProfileLoading) {
          return const SkeletonLoading(
            variant: SkeletonVariant.listItem,
            count: 3,
          );
        }

        if (state is HealthProfileLoaded) {
          if (state.goals.isEmpty) {
            return const GoalEmptyState();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.goals.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.md.h),
            itemBuilder: (context, index) {
              final goal = state.goals[index];
              return GoalCard(
                goal: goal,
                onViewDetail: () => _showGoalDetail(context, goal),
                onUpdate: () => _navigateToGoalForm(
                  context,
                  goal.userId,
                  goalId: goal.id,
                  goal: goal,
                ),
                onDelete: () => _confirmDelete(context, goal),
              );
            },
          );
        }

        if (state is HealthProfileError) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: AppTypography.bodyRegularStyle(
                fontSize: AppTypography.fontSizeSm.sp,
                color: AppColors.error,
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _refreshGoals(BuildContext context) {
    final authState = context.read<AuthenticationBloc>().state;
    if (authState is AuthenticationAuthenticated) {
      context.read<HealthProfileBloc>().add(
        GetHealthProfileGoalsEvent(authState.user.id),
      );
    }
  }

  Future<void> _navigateToGoalForm(
    BuildContext context,
    String userId, {
    String? goalId,
    GoalEntity? goal,
  }) async {
    final result = await RouteConfig.navigateToGoalForm(
      context,
      goalId: goalId,
      goal: goal,
      userId: userId,
    );

    if (result == true && context.mounted) {
      _refreshGoals(context);
    }
  }

  void _showGoalDetail(BuildContext context, GoalEntity goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalDetailBottomSheet(
        goal: goal,
        onUpdate: () {
          Navigator.pop(context);
          _navigateToGoalForm(
            context,
            goal.userId,
            goalId: goal.id,
            goal: goal,
          );
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, goal);
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, GoalEntity goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Goal',
          style: AppTypography.headingBoldStyle(
            fontSize: AppTypography.fontSizeLg.sp,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this goal?',
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
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GoalBloc>().add(
                DeleteGoalEvent(goal.id!, goal.userId),
              );
            },
            child: Text(
              'Delete',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase.sp,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
