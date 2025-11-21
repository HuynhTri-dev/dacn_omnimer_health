import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';

import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_detail_header.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_detail_body.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/widgets/exercise_rating_sheet.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final List<String> muscleNames;

  const ExerciseDetailScreen({
    Key? key,
    required this.exercise,
    required this.muscleNames,
  }) : super(key: key);

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  double _currentRating = 0;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.exercise.rating ?? 0;
    _loadRatingFromServer();
  }

  Future<void> _loadRatingFromServer() async {
    try {
      final apiClient = sl<ApiClient>();
      final repo = ExerciseRepository(apiClient.dio);

      final rating = await repo.getExerciseRatingFromServer(widget.exercise.id);

      if (!mounted) return;

      if (rating != null && rating > 0) {
        setState(() {
          _currentRating = rating;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final apiClient = sl<ApiClient>();
        final repo = ExerciseRepository(apiClient.dio);
        return ExerciseDetailCubit(repo);
      },
      child: Builder(
        builder: (blocContext) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                children: [
                  ExerciseDetailHeader(
                    exerciseName: widget.exercise.name,
                    currentRating: _currentRating,
                    onBack: () {
                      final result = _currentRating <= 0
                          ? null
                          : _currentRating;
                      Navigator.of(blocContext).pop(result);
                    },
                  ),

                  Expanded(
                    child: ExerciseDetailBody(
                      exercise: widget.exercise,
                      muscleNames: widget.muscleNames,
                    ),
                  ),
                ],
              ),
            ),

            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
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
                    parentContext: blocContext,
                    exercise: widget.exercise,
                    currentRating: _currentRating,
                    onRatingUpdated: (newRating) {
                      setState(() {
                        _currentRating = newRating;
                      });
                    },
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
            ),
          );
        },
      ),
    );
  }
}
