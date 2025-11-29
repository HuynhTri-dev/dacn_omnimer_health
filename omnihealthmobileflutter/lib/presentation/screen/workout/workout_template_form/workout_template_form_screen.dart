import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/cubits/workout_template_form_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/cubits/workout_template_form_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/cubits/exercise_selection_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/cubits/exercise_selection_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/cubits/template_details_cubit.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_template_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/create_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/update_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';

part 'widgets/template_header.dart';
part 'widgets/template_detail_card.dart';
part 'widgets/exercise_item.dart';
part 'widgets/set_row.dart';
part 'widgets/add_detail_dialog.dart';
part 'widgets/add_exercise_sheet.dart';

class WorkoutTemplateFormScreen extends StatelessWidget {
  final String? templateId; // null for create, non-null for edit

  const WorkoutTemplateFormScreen({
    super.key,
    this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = WorkoutTemplateFormCubit(
          getWorkoutTemplateByIdUseCase:
              templateId != null ? sl<GetWorkoutTemplateByIdUseCase>() : null,
          createWorkoutTemplateUseCase: sl<CreateWorkoutTemplateUseCase>(),
          updateWorkoutTemplateUseCase: sl<UpdateWorkoutTemplateUseCase>(),
        );

        if (templateId != null) {
          cubit.initializeForEdit(templateId!);
        } else {
          cubit.initializeForCreate();
        }

        return cubit;
      },
      child: const _WorkoutTemplateFormView(),
    );
  }
}

class _WorkoutTemplateFormView extends StatelessWidget {
  const _WorkoutTemplateFormView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocConsumer<WorkoutTemplateFormCubit, WorkoutTemplateFormState>(
          listener: (context, state) {
            if (state.status == WorkoutTemplateFormStatus.saved) {
              Navigator.of(context).pop(true); // Return true to indicate success
            } else if (state.status == WorkoutTemplateFormStatus.error && 
                       state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WorkoutTemplateFormStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Header
                _TemplateHeader(
                  name: state.name,
                  onNameChanged: (value) {
                    context.read<WorkoutTemplateFormCubit>().updateName(value);
                  },
                  onBack: () => Navigator.of(context).pop(),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Detail Card
                        _TemplateDetailCard(
                          onAddDetail: () => _showAddDetailDialog(context),
                          onAddExercises: () => _showAddExerciseSheet(context),
                        ),

                        SizedBox(height: AppSpacing.md.h),

                        // Exercises Section Title
                        if (state.exercises.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.md.h),
                            child: Text(
                              'Exercises (${state.exercises.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),

                        // Exercises List
                        if (state.exercises.isEmpty)
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
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.grey,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.exercises.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final exercise = state.exercises[index];
                              return _ExerciseItem(
                                exercise: exercise,
                                exerciseIndex: index,
                                onRemove: () {
                                  context
                                      .read<WorkoutTemplateFormCubit>()
                                      .removeExercise(index);
                                },
                              );
                            },
                          ),

                        SizedBox(height: 80.h), // Space for save button
                      ],
                    ),
                  ),
                ),

                // Save Button (fixed at bottom)
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                  child: ElevatedButton(
                    onPressed: state.status == WorkoutTemplateFormStatus.saving
                        ? null
                        : () => _handleSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          state.status == WorkoutTemplateFormStatus.saving
                              ? 'Saving...'
                              : 'Save Template',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<WorkoutTemplateFormCubit>(),
          ),
          BlocProvider(
            create: (_) => TemplateDetailsCubit(
              getAllBodyPartsUseCase: sl<GetAllBodyPartsUseCase>(),
              getAllEquipmentsUseCase: sl<GetAllEquipmentsUseCase>(),
              getAllExerciseCategoriesUseCase: sl<GetAllExerciseCategoriesUseCase>(),
              getAllExerciseTypesUseCase: sl<GetAllExerciseTypesUseCase>(),
              getAllMusclesUseCase: sl<GetAllMuscleTypesUseCase>(),
            ),
          ),
        ],
        child: const _AddDetailDialog(),
      ),
    );
  }

  void _showAddExerciseSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: context.read<WorkoutTemplateFormCubit>(),
          ),
          BlocProvider(
            create: (_) => ExerciseSelectionCubit(
              getExercisesUseCase: sl<GetExercisesUseCase>(),
            )..loadExercises(),
          ),
        ],
        child: const _AddExerciseSheet(),
      ),
    );
  }

  void _handleSave(BuildContext context) async {
    final cubit = context.read<WorkoutTemplateFormCubit>();
    
    final success = await cubit.saveTemplate();
    
    if (!success && context.mounted) {
      // Error message already handled by cubit listener
      // Just stay on the page
    }
  }
}

