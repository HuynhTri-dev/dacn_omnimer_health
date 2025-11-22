import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_state.dart';

import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_detail_header.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_detail_body.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_rating_sheet.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetailScreen({Key? key, required this.exerciseId})
    : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load exercise details when screen is created
    context.read<ExerciseDetailCubit>().loadExerciseDetail(widget.exerciseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
          builder: (context, state) {
            // Loading state
            if (state.status == ExerciseDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (state.status == ExerciseDetailStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading exercise',
                      style: AppTypography.h3.copyWith(color: AppColors.error),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.errorMessage ?? 'Unknown error',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ExerciseDetailCubit>().loadExerciseDetail(
                          widget.exerciseId,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // No data state
            if (state.exercise == null) {
              return const Center(child: Text('No exercise data'));
            }

            final exercise = state.exercise!;
            final muscleNames = [
              ...exercise.mainMuscles.map((m) => m.name),
              ...exercise.secondaryMuscles.map((m) => m.name),
            ];

            return Column(
              children: [
                ExerciseDetailHeader(
                  exerciseName: exercise.name,
                  currentRating: state.userRating ?? 0.0,
                  onBack: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: ExerciseDetailBody(
                    exercise: exercise,
                    muscleNames: muscleNames,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          BlocBuilder<ExerciseDetailCubit, ExerciseDetailState>(
            builder: (context, state) {
              if (state.exercise == null) return const SizedBox.shrink();

              return Padding(
                padding: EdgeInsets.only(right: 16.w, bottom: 8.h),
                child: Material(
                  elevation: 6,
                  borderRadius: AppRadius.radiusLg,
                  color: Colors.transparent,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () => showExerciseRatingSheet(
                      parentContext: context,
                      exerciseId: widget.exerciseId,
                      exerciseName: state.exercise!.name,
                      currentRating: state.userRating ?? 0.0,
                    ),
                    child: Text(
                      'Rating',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
