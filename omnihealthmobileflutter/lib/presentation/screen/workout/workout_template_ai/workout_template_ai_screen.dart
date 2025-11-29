import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_icon.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/multi_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_state.dart';

class WorkoutTemplateAIScreen extends StatelessWidget {
  const WorkoutTemplateAIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<WorkoutTemplateAICubit>()..loadInitialData(),
      child: const _WorkoutTemplateAIView(),
    );
  }
}

class _WorkoutTemplateAIView extends StatelessWidget {
  const _WorkoutTemplateAIView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8.0.w),
          child: ButtonIcon(
            icon: const Icon(Icons.arrow_back),
            variant: ButtonIconVariant.secondaryOutline,
            onPressed: () => Navigator.pop(context),
            size: ButtonIconSize.small,
          ),
        ),
        title: const Text("AI Workout Recommendation"),
        centerTitle: true,
      ),
      body: BlocConsumer<WorkoutTemplateAICubit, WorkoutTemplateAIState>(
        listener: (context, state) {
          if (state.status == WorkoutTemplateAIStatus.success &&
              state.recommendedWorkout != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Workout Created: ${state.recommendedWorkout!.name}",
                ),
              ),
            );
            // TODO: Navigate to workout detail if needed
          } else if (state.status == WorkoutTemplateAIStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred"),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == WorkoutTemplateAIStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Body Parts
                MultiSelectBox<String>(
                  label: "Body Parts",
                  placeholder: "Select Body Parts",
                  options: state.bodyParts
                      .map((e) => MultiSelectItem(e.id, e.name))
                      .toList(),
                  value: state.selectedBodyPartIds,
                  onChanged: (values) {
                    context
                        .read<WorkoutTemplateAICubit>()
                        .updateSelectedBodyParts(values);
                  },
                ),
                SizedBox(height: AppSpacing.md.h),

                // Equipments
                MultiSelectBox<String>(
                  label: "Equipments",
                  placeholder: "Select Equipments",
                  options: state.equipments
                      .map((e) => MultiSelectItem(e.id, e.name))
                      .toList(),
                  value: state.selectedEquipmentIds,
                  onChanged: (values) {
                    context
                        .read<WorkoutTemplateAICubit>()
                        .updateSelectedEquipments(values);
                  },
                ),
                SizedBox(height: AppSpacing.md.h),

                // Exercise Categories
                MultiSelectBox<String>(
                  label: "Exercise Categories",
                  placeholder: "Select Categories",
                  options: state.exerciseCategories
                      .map((e) => MultiSelectItem(e.id, e.name))
                      .toList(),
                  value: state.selectedExerciseCategoryIds,
                  onChanged: (values) {
                    context
                        .read<WorkoutTemplateAICubit>()
                        .updateSelectedCategories(values);
                  },
                ),
                SizedBox(height: AppSpacing.md.h),

                // Exercise Types
                MultiSelectBox<String>(
                  label: "Exercise Types",
                  placeholder: "Select Types",
                  options: state.exerciseTypes
                      .map((e) => MultiSelectItem(e.id, e.name))
                      .toList(),
                  value: state.selectedExerciseTypeIds,
                  onChanged: (values) {
                    context.read<WorkoutTemplateAICubit>().updateSelectedTypes(
                      values,
                    );
                  },
                ),
                SizedBox(height: AppSpacing.md.h),

                // Muscles
                MultiSelectBox<String>(
                  label: "Muscles",
                  placeholder: "Select Muscles",
                  options: state.muscles
                      .map((e) => MultiSelectItem(e.id, e.name))
                      .toList(),
                  value: state.selectedMuscleIds,
                  onChanged: (values) {
                    context
                        .read<WorkoutTemplateAICubit>()
                        .updateSelectedMuscles(values);
                  },
                ),
                SizedBox(height: AppSpacing.md.h),

                // Location
                SingleSelectBox<LocationEnum>(
                  label: "Location",
                  placeholder: "Select Location",
                  options: LocationEnum.values
                      .map((e) => SelectOption(label: e.displayName, value: e))
                      .toList(),
                  value: state.selectedLocation,
                  onChanged: (value) {
                    context
                        .read<WorkoutTemplateAICubit>()
                        .updateSelectedLocation(value);
                  },
                ),
                SizedBox(height: AppSpacing.xl.h),

                // Submit Button
                ButtonPrimary(
                  title: "Create Workout By ID",
                  onPressed: () {
                    context.read<WorkoutTemplateAICubit>().createWorkoutById();
                  },
                  loading: state.status == WorkoutTemplateAIStatus.submitting,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
