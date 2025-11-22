import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/muscle_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';
import 'package:omnihealthmobileflutter/presentation/common/skeleton/skeleton_loading.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_state.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_cube/flutter_cube.dart';

part 'widgets/header_and_search.dart';
part 'widgets/exercise_list.dart';
part 'widgets/exercise_list_skeleton.dart';
part 'widgets/filter_sheet.dart';

class ExerciseHomeScreen extends StatelessWidget {
  const ExerciseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ExerciseHomeView();
  }
}

class _ExerciseHomeView extends StatefulWidget {
  const _ExerciseHomeView();

  @override
  State<_ExerciseHomeView> createState() => _ExerciseHomeViewState();
}

class _ExerciseHomeViewState extends State<_ExerciseHomeView> {
  @override
  void initState() {
    super.initState();
    // Load initial data when screen is created
    context.read<ExerciseHomeBloc>().add(LoadInitialData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const UserHeaderWidget(),
            Expanded(
              child: BlocBuilder<ExerciseHomeBloc, ExerciseHomeState>(
                builder: (context, state) {
                  // Loading filters
                  if (state.status == ExerciseHomeStatus.loadingFilters) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Đang tải dữ liệu...'),
                        ],
                      ),
                    );
                  }

                  // Error state
                  if (state.status == ExerciseHomeStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đã xảy ra lỗi\n${state.errorMessage ?? "Unknown error"}',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ExerciseHomeBloc>().add(
                                LoadInitialData(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Loading exercises
                  if (state.status == ExerciseHomeStatus.loadingExercises &&
                      state.exercises.isEmpty) {
                    return const _ExerciseListSkeleton();
                  }

                  // Empty state
                  if (state.exercises.isEmpty &&
                      state.status == ExerciseHomeStatus.exercisesLoaded) {
                    return Center(
                      child: Text(
                        'Không có bài tập',
                        style: AppTypography.bodyMedium,
                      ),
                    );
                  }

                  // Main content
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
                                value: state.searchQuery ?? '',
                                onChanged: (value) {
                                  context.read<ExerciseHomeBloc>().add(
                                    SearchExercises(value),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),
                            _FilterButton(
                              resultCount: state.exercises.length,
                              onPressed: () async {
                                // Lấy bloc hiện tại từ context của màn hình
                                final bloc = context.read<ExerciseHomeBloc>();

                                await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (ctx) {
                                    // "Mang" lại bloc vào trong bottom sheet
                                    return BlocProvider.value(
                                      value: bloc,
                                      child: _FilterSheet(state: state),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // Exercise list
                        _ExerciseList(
                          exercises: state.exercises,
                          muscles: state.muscles,
                          isLoadingMore:
                              state.status == ExerciseHomeStatus.loadingMore,
                          hasMore: state.hasMoreExercises,
                          onLoadMore: () {
                            context.read<ExerciseHomeBloc>().add(
                              LoadMoreExercises(),
                            );
                          },
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
