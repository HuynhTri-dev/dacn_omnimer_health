import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_detail/cubits/workout_template_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_detail/cubits/workout_template_detail_state.dart';

part 'widgets/template_detail_header.dart';
part 'widgets/template_info_section.dart';
part 'widgets/exercise_detail_card.dart';

class WorkoutTemplateDetailScreen extends StatefulWidget {
  final String templateId;

  const WorkoutTemplateDetailScreen({
    super.key,
    required this.templateId,
  });

  @override
  State<WorkoutTemplateDetailScreen> createState() =>
      _WorkoutTemplateDetailScreenState();
}

class _WorkoutTemplateDetailScreenState
    extends State<WorkoutTemplateDetailScreen> {
  // Track if any changes were made (edit, etc.)
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    context.read<WorkoutTemplateDetailCubit>().loadTemplateDetail(widget.templateId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<WorkoutTemplateDetailCubit, WorkoutTemplateDetailState>(
          listener: (context, state) {
            // Handle deleted state - go back to home
            if (state.status == WorkoutTemplateDetailStatus.deleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Template deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop(true); // Return true to trigger reload
            }
            
            // Handle error message during delete
            if (state.errorMessage != null && 
                state.status == WorkoutTemplateDetailStatus.loaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            // Loading state
            if (state.status == WorkoutTemplateDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Deleting state
            if (state.status == WorkoutTemplateDetailStatus.deleting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    Text(
                      'Deleting template...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            // Error state
            if (state.status == WorkoutTemplateDetailStatus.error) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        state.errorMessage ?? 'An error occurred',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<WorkoutTemplateDetailCubit>()
                              .loadTemplateDetail(widget.templateId);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // No data state
            if (state.template == null) {
              return Center(
                child: Text(
                  'No data available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            final template = state.template!;

            return Column(
              children: [
                // Header
                _TemplateDetailHeader(
                  template: template,
                  onBack: () => Navigator.of(context).pop(_hasChanges),
                  onEdit: () async {
                    // Navigate to edit screen and wait for result
                    final result = await Navigator.of(context).pushNamed(
                      '/workout-template-form',
                      arguments: {'templateId': template.id},
                    );
                    
                    // Reload template if save was successful
                    if (result == true && context.mounted) {
                      _hasChanges = true; // Mark that changes were made
                      context
                          .read<WorkoutTemplateDetailCubit>()
                          .loadTemplateDetail(widget.templateId);
                    }
                  },
                  onDelete: () {
                    context
                        .read<WorkoutTemplateDetailCubit>()
                        .deleteTemplate(widget.templateId);
                  },
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Section
                        _TemplateInfoSection(template: template),

                        SizedBox(height: AppSpacing.lg.h),

                        // Exercises Section Title
                        Text(
                          'Exercises (${template.workOutDetail.length})',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        SizedBox(height: AppSpacing.md.h),

                        // Exercises List
                        if (template.workOutDetail.isEmpty)
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
                                    'No exercises added yet',
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
                            itemCount: template.workOutDetail.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final exercise = template.workOutDetail[index];
                              return _ExerciseDetailCard(
                                exercise: exercise,
                                index: index + 1,
                              );
                            },
                          ),

                        SizedBox(height: 80.h), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<WorkoutTemplateDetailCubit, WorkoutTemplateDetailState>(
        builder: (context, state) {
          if (state.template == null) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () {
              RouteConfig.navigateToWorkoutSession(
                context,
                template: state.template!,
              );
            },
            backgroundColor: Theme.of(context).primaryColor,
            icon: const Icon(Icons.play_arrow, color: Colors.white),
            label: const Text(
              'Start Workout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }
}

