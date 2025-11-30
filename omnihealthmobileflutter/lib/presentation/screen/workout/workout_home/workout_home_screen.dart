import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/workout_frequency_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/widgets/action_buttons.dart';

part 'widgets/weekly_workout_chart.dart';
part 'widgets/workout_template_card.dart';

class WorkoutHomeScreen extends StatelessWidget {
  const WorkoutHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkoutHomeView();
  }
}

class _WorkoutHomeView extends StatefulWidget {
  const _WorkoutHomeView();

  @override
  State<_WorkoutHomeView> createState() => _WorkoutHomeViewState();
}

class _WorkoutHomeViewState extends State<_WorkoutHomeView> {
  @override
  void initState() {
    super.initState();
    // Load initial data when screen is created
    context.read<WorkoutHomeBloc>().add(LoadInitialWorkoutData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const UserHeaderWidget(),
            Expanded(
              child: BlocBuilder<WorkoutHomeBloc, WorkoutHomeState>(
                builder: (context, state) {
                  // Loading state
                  if (state.status == WorkoutHomeStatus.loading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading data...'),
                        ],
                      ),
                    );
                  }

                  // Error state
                  if (state.status == WorkoutHomeStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'An error occurred\n${state.errorMessage ?? "Unknown error"}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<WorkoutHomeBloc>().add(
                                LoadInitialWorkoutData(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Main content
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WorkoutHomeBloc>().add(RefreshWorkoutData());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Weekly Workout Chart
                          if (state.workoutFrequency != null)
                            _WeeklyWorkoutChart(
                              frequencyData: state.workoutFrequency!,
                            ),

                          SizedBox(height: AppSpacing.md.h),

                          // Title "My Template Workout"
                          Text(
                            'My Template Workout',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: AppSpacing.md.h),

                          // Action Buttons (3T-FIT and Create)
                          const ActionButtons(),

                          SizedBox(height: AppSpacing.md.h),

                          // Workout Templates List
                          if (state.templates.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40.h),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.fitness_center_outlined,
                                      size: 64.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      'No workout templates yet',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.templates.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final template = state.templates[index];
                                return _WorkoutTemplateCard(
                                  template: template,
                                  onTap: () async {
                                    final result =
                                        await RouteConfig.navigateToWorkoutTemplateDetail(
                                          context,
                                          templateId: template.id,
                                        );

                                    // Reload if there were changes
                                    if (result == true && context.mounted) {
                                      context.read<WorkoutHomeBloc>().add(
                                        RefreshWorkoutData(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
