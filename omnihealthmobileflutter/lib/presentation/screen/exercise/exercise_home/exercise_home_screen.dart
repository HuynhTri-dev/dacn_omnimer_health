import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';

import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';

import 'package:omnihealthmobileflutter/data/models/exercise/exercise_model.dart';
import 'package:omnihealthmobileflutter/data/models/muscle/muscle_model.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/exercise_detail_screen.dart';

import 'cubits/exercise_cubit.dart';
import 'cubits/exercise_state.dart';

part 'widgets/header_and_search.dart';
part 'widgets/exercise_list.dart';
part 'widgets/filter_sheet.dart';

class ExerciseHomeScreen extends StatelessWidget {
  const ExerciseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng ApiClient đã cấu hình sẵn (baseUrl + interceptor + token)
    final apiClient = sl<ApiClient>();
    debugPrint('Exercise API baseUrl = ${apiClient.dio.options.baseUrl}');

    final repo = ExerciseRepository(apiClient.dio);

    return BlocProvider(
      create: (_) => ExerciseCubit(repo)..loadData(),
      child: const _ExerciseHomeView(),
    );
  }
}

class _ExerciseHomeView extends StatelessWidget {
  const _ExerciseHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const UserHeaderWidget(),
            Expanded(
              child: BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return Center(
                      child: Text(
                        'Đã xảy ra lỗi\n${state.error}',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    );
                  }

                  if (state.exercises.isEmpty) {
                    return Center(
                      child: Text(
                        'Không có bài tập',
                        style: AppTypography.bodyMedium,
                      ),
                    );
                  }

                  // TÍNH DANH SÁCH SAU KHI LỌC ĐỂ ĐẾM SỐ LƯỢNG
                  final exercises = state.exercises;
                  final filter = state.filter;
                  Iterable<ExerciseModel> countResult = exercises;

                  // lọc theo muscle đang chọn
                  if (state.selectedMuscle != null) {
                    countResult = countResult.where(
                      (e) => e.mainMuscles.contains(state.selectedMuscle!.id),
                    );
                  }

                  // lọc theo search
                  final query = state.search.trim().toLowerCase();
                  if (query.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => e.name.toLowerCase().contains(query),
                    );
                  }

                  // lọc theo filter nâng cao (giống _ExerciseList)
                  if (filter.equipmentIds.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => filter.equipmentIds.contains(e.equipment),
                    );
                  }
                  if (filter.muscleIds.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => e.mainMuscles.any(filter.muscleIds.contains),
                    );
                  }
                  if (filter.exerciseTypes.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => filter.exerciseTypes.contains(e.type),
                    );
                  }
                  if (filter.exerciseCategories.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => filter.exerciseCategories.contains(e.category),
                    );
                  }
                  if (filter.locations.isNotEmpty) {
                    countResult = countResult.where(
                      (e) => filter.locations.contains(e.location),
                    );
                  }

                  final filteredCount = countResult.length;

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP: human model + muscle card
                        _BodyAndMuscleHeader(
                          selectedMuscle: state.selectedMuscle,
                        ),
                        SizedBox(height: 20.h),

                        // Title "Exercise"
                        Text('Exercise', style: AppTypography.h2),
                        SizedBox(height: 12.h),

                        // Search + filter button
                        Row(
                          children: [
                            Expanded(
                              child: _SearchField(
                                value: state.search,
                                onChanged: (value) => context
                                    .read<ExerciseCubit>()
                                    .updateSearch(value),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            _FilterButton(
                              resultCount: filteredCount,
                              onPressed: () async {
                                final filter =
                                    await showModalBottomSheet<ExerciseFilter>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) {
                                        return _ExerciseFilterSheet(
                                          exercises: state.exercises,
                                          muscles: state.muscles,
                                          initial: state.filter,
                                        );
                                      },
                                    );

                                if (filter != null && context.mounted) {
                                  context.read<ExerciseCubit>().updateFilter(
                                    filter,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        _ExerciseList(
                          exercises: state.exercises,
                          muscles: state.muscles,
                          selectedMuscle: state.selectedMuscle,
                          search: state.search,
                          filter: state.filter,
                        ),
                      ],
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
