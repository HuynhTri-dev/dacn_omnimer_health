import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/multi_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/single_select_box.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_state.dart';

class WorkoutTemplateAIScreen extends StatelessWidget {
  const WorkoutTemplateAIScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
            Navigator.of(context).pop(true);
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

          if (state.status == WorkoutTemplateAIStatus.submitting) {
            return const _AILoadingView();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AIHeader(),
                SizedBox(height: AppSpacing.lg.h),
                _AIForm(state: state),
                SizedBox(height: AppSpacing.xl.h),
                ButtonPrimary(
                  title: "Generate Workout",
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

class _AIHeader extends StatelessWidget {
  const _AIHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            size: 40.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Powered",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Let our AI design the perfect workout for you based on your preferences.",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AIForm extends StatelessWidget {
  final WorkoutTemplateAIState state;

  const _AIForm({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MultiSelectBox<String>(
          label: "Body Parts",
          placeholder: "Select Body Parts",
          options: state.bodyParts
              .map((e) => MultiSelectItem(e.id, e.name))
              .toList(),
          value: state.selectedBodyPartIds,
          onChanged: (values) {
            context.read<WorkoutTemplateAICubit>().updateSelectedBodyParts(
              values,
            );
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        MultiSelectBox<String>(
          label: "Equipments",
          placeholder: "Select Equipments",
          options: state.equipments
              .map((e) => MultiSelectItem(e.id, e.name))
              .toList(),
          value: state.selectedEquipmentIds,
          onChanged: (values) {
            context.read<WorkoutTemplateAICubit>().updateSelectedEquipments(
              values,
            );
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        MultiSelectBox<String>(
          label: "Exercise Categories",
          placeholder: "Select Categories",
          options: state.exerciseCategories
              .map((e) => MultiSelectItem(e.id, e.name))
              .toList(),
          value: state.selectedExerciseCategoryIds,
          onChanged: (values) {
            context.read<WorkoutTemplateAICubit>().updateSelectedCategories(
              values,
            );
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        MultiSelectBox<String>(
          label: "Exercise Types",
          placeholder: "Select Types",
          options: state.exerciseTypes
              .map((e) => MultiSelectItem(e.id, e.name))
              .toList(),
          value: state.selectedExerciseTypeIds,
          onChanged: (values) {
            context.read<WorkoutTemplateAICubit>().updateSelectedTypes(values);
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        MultiSelectBox<String>(
          label: "Muscles",
          placeholder: "Select Muscles",
          options: state.muscles
              .map((e) => MultiSelectItem(e.id, e.name))
              .toList(),
          value: state.selectedMuscleIds,
          onChanged: (values) {
            context.read<WorkoutTemplateAICubit>().updateSelectedMuscles(
              values,
            );
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        SingleSelectBox<LocationEnum>(
          label: "Location",
          placeholder: "Select Location",
          options: LocationEnum.values
              .map((e) => SelectOption(label: e.displayName, value: e))
              .toList(),
          value: state.selectedLocation,
          onChanged: (value) {
            context.read<WorkoutTemplateAICubit>().updateSelectedLocation(
              value,
            );
          },
        ),
        SizedBox(height: AppSpacing.md.h),
        CustomTextField(
          label: "Number of Exercises",
          placeholder: "Enter number of exercises (default 5)",
          value: state.k.toString(),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final k = int.tryParse(value);
            if (k != null) {
              context.read<WorkoutTemplateAICubit>().updateK(k);
            }
          },
        ),
      ],
    );
  }
}

class _AILoadingView extends StatefulWidget {
  const _AILoadingView({Key? key}) : super(key: key);

  @override
  State<_AILoadingView> createState() => _AILoadingViewState();
}

class _AILoadingViewState extends State<_AILoadingView> {
  String _message = "Analyzing your health profile...";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _message = "Creating your personalized workout...";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            _message,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            "Please wait a moment",
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
