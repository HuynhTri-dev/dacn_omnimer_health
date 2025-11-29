// lib/presentation/screen/exercise/exercise_home/widgets/exercise_list.dart
part of '../exercise_home_screen.dart';

class _ExerciseList extends StatelessWidget {
  final List<ExerciseListEntity> exercises;
  final List<MuscleEntity> muscles;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _ExerciseList({
    required this.exercises,
    required this.muscles,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'Không tìm thấy bài tập',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (_, __) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final exercise = exercises[index];

            final muscleNames = exercise.mainMuscles
                .map((muscle) => muscle.name)
                .where((name) => name.isNotEmpty)
                .toList();

            return _ExerciseCard(exercise: exercise, muscleNames: muscleNames);
          },
        ),

        if (hasMore)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: ButtonPrimary(
              title: 'Load more',
              variant: ButtonVariant.primaryOutline,
              fullWidth: true,
              loading: isLoadingMore,
              onPressed: isLoadingMore ? null : onLoadMore,
            ),
          ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseListEntity exercise;
  final List<String> muscleNames;

  const _ExerciseCard({required this.exercise, required this.muscleNames});

  /// Placeholder when no image available
  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 85.w,
      height: 85.w,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Icon(
        Icons.fitness_center,
        size: 32.sp,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  /// Thumbnail: use exercise image
  Widget _buildThumbnail(BuildContext context) {
    if (exercise.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radiusMd,
        child: Image.network(
          exercise.imageUrl,
          width: 85.w,
          height: 85.w,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint(
              'Error loading image for ${exercise.name}: ${exercise.imageUrl}',
            );
            debugPrint('Error details: $error');
            return _buildPlaceholder(context);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 85.w,
              height: 85.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.08),
                borderRadius: AppRadius.radiusMd,
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    return _buildPlaceholder(context);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.radiusLg,
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed('/exercise-detail', arguments: {'exerciseId': exercise.id});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail on the left
            _buildThumbnail(context),
            SizedBox(width: 12.w),

            // Content on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Exercise name + status indicator
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Muscle names
                  Text(
                    muscleNames.isEmpty ? '-' : muscleNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Equipment and Location
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          label: 'Equipment',
                          value: exercise.equipments.isNotEmpty
                              ? exercise.equipments.first.name
                              : '-',
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _InfoRow(
                          label: 'Location',
                          value: exercise.location,
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _InfoRow({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final textAlign = alignEnd ? TextAlign.end : TextAlign.start;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? '-' : value,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
