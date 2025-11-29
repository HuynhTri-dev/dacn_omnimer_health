part of '../workout_template_form_screen.dart';

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet();

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: BlocBuilder<ExerciseSelectionCubit, ExerciseSelectionState>(
        builder: (context, state) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Add Exercise',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<ExerciseSelectionCubit>()
                                  .updateSearchQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  onChanged: (value) {
                    context
                        .read<ExerciseSelectionCubit>()
                        .updateSearchQuery(value);
                  },
                ),
              ),

              SizedBox(height: 12.h),

              // Filter chips
              SizedBox(
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    if (state.selectedEquipmentIds.isNotEmpty ||
                        state.selectedMuscleIds.isNotEmpty ||
                        state.selectedDifficulty != null)
                      _FilterChip(
                        label: 'Clear Filters',
                        isActive: true,
                        onTap: () {
                          context
                              .read<ExerciseSelectionCubit>()
                              .clearFilters();
                        },
                      ),
                    if (state.selectedEquipmentIds.isNotEmpty ||
                        state.selectedMuscleIds.isNotEmpty ||
                        state.selectedDifficulty != null)
                      SizedBox(width: 8.w),
                    _FilterChip(
                      label: state.selectedDifficulty != null
                          ? 'Difficulty: ${state.selectedDifficulty}'
                          : 'Difficulty',
                      isActive: state.selectedDifficulty != null,
                      onTap: () => _showDifficultyFilter(context),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Exercise list
              Expanded(
                child: _buildExerciseList(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    ExerciseSelectionState state,
  ) {
    if (state.status == ExerciseSelectionStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ExerciseSelectionStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              state.errorMessage ?? 'Failed to load exercises',
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<ExerciseSelectionCubit>().loadExercises();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filteredExercises = state.filteredExercises;

    if (filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No exercises found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: filteredExercises.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return _ExerciseListItem(
          exercise: exercise,
          onTap: () {
            // Add exercise using the workout template form cubit
            context.read<WorkoutTemplateFormCubit>().addExercise(exercise);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${exercise.name}'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.green,
              ),
            );

            // Close the sheet
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _showDifficultyFilter(BuildContext context) {
    final difficulties = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<ExerciseSelectionCubit>(),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Difficulty',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ...difficulties.map((difficulty) {
                return ListTile(
                  title: Text(difficulty),
                  onTap: () {
                    context
                        .read<ExerciseSelectionCubit>()
                        .updateDifficultyFilter(difficulty);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? Theme.of(context).primaryColor
                : Theme.of(context).primaryColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isActive ? Colors.white : Theme.of(context).primaryColor,
              ),
            ),
            if (!isActive) ...[
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).primaryColor,
                size: 20.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseListItem extends StatelessWidget {
  final ExerciseListEntity exercise;
  final VoidCallback onTap;

  const _ExerciseListItem({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Exercise image
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: exercise.imageUrl.isNotEmpty
                  ? Image.network(
                      exercise.imageUrl,
                      fit: BoxFit.cover,
                      width: 50.w,
                      height: 50.w,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.fitness_center,
                          color: Colors.grey[500],
                          size: 24.sp,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.fitness_center,
                      color: Colors.grey[500],
                      size: 24.sp,
                    ),
            ),

            SizedBox(width: 12.w),

            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      if (exercise.equipments.isNotEmpty) ...[
                        Text(
                          exercise.equipments[0].name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text('•', style: TextStyle(color: Colors.grey[600])),
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add button
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).primaryColor,
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}

