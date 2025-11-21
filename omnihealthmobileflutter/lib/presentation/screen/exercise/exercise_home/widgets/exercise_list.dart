// lib/presentation/screen/exercise/exercise_home/widgets/exercise_list.dart
part of '../exercise_home_screen.dart';

class _ExerciseList extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final List<MuscleModel> muscles;
  final MuscleModel? selectedMuscle;
  final String search;
  final ExerciseFilter filter;

  const _ExerciseList({
    required this.exercises,
    required this.muscles,
    required this.selectedMuscle,
    required this.search,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'Không tìm thấy bài tập',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    // map id -> name & id -> MuscleModel cho muscles
    final muscleNameMap = {for (final m in muscles) m.id: m.name};
    final muscleMap = {for (final m in muscles) m.id: m};

    Iterable<ExerciseModel> result = exercises;

    // lọc theo muscle đang chọn ở thanh trên
    if (selectedMuscle != null) {
      result = result.where((e) => e.mainMuscles.contains(selectedMuscle!.id));
    }

    // lọc theo search
    final query = search.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((e) => e.name.toLowerCase().contains(query));
    }

    // lọc theo filter nâng cao
    if (filter.equipmentIds.isNotEmpty) {
      result = result.where((e) => filter.equipmentIds.contains(e.equipment));
    }
    if (filter.muscleIds.isNotEmpty) {
      result = result.where(
        (e) => e.mainMuscles.any(filter.muscleIds.contains),
      );
    }
    if (filter.exerciseTypes.isNotEmpty) {
      result = result.where((e) => filter.exerciseTypes.contains(e.type));
    }
    if (filter.exerciseCategories.isNotEmpty) {
      result = result.where(
        (e) => filter.exerciseCategories.contains(e.category),
      );
    }
    if (filter.locations.isNotEmpty) {
      result = result.where((e) => filter.locations.contains(e.location));
    }

    final list = result.toList();

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Text(
            'Không có bài tập phù hợp với bộ lọc',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final exercise = list[index];

        // danh sách tên muscle cho bài tập này
        final muscleNames = exercise.mainMuscles
            .map((id) => muscleNameMap[id] ?? '')
            .where((name) => name.isNotEmpty)
            .toList();

        // muscle đầu tiên (dùng làm thumbnail / focus chính)
        MuscleModel? mainMuscle;
        if (exercise.mainMuscles.isNotEmpty) {
          mainMuscle = muscleMap[exercise.mainMuscles.first];
        }

        return _ExerciseCard(
          exercise: exercise,
          muscleNameMap: muscleNameMap,
          mainMuscle: mainMuscle,
          muscleNames: muscleNames,
        );
      },
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;
  final Map<String, String> muscleNameMap;
  final MuscleModel? mainMuscle;
  final List<String> muscleNames;

  const _ExerciseCard({
    required this.exercise,
    required this.muscleNameMap,
    required this.mainMuscle,
    required this.muscleNames,
  });

  /// Placeholder khi không có ảnh / lỗi ảnh
  Widget _buildPlaceholder() {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: AppRadius.radiusMd,
      ),
      child: const Icon(
        Icons.fitness_center,
        size: 24,
        color: AppColors.primary,
      ),
    );
  }

  /// Thumbnail: ưu tiên ảnh bài tập, nếu không có thì lấy ảnh muscle chính
  Widget _buildThumbnail() {
    // 1. Ảnh riêng của bài tập
    if (exercise.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radiusMd,
        child: Image.network(
          exercise.image,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }

    // 2. Nếu không có, thử dùng ảnh mainMuscle
    final muscleImage = mainMuscle?.image ?? '';
    if (muscleImage.isNotEmpty) {
      return ClipRRect(
        borderRadius: AppRadius.radiusMd,
        child: Image.network(
          muscleImage,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }

    // 3. Không có gì hết -> placeholder
    return _buildPlaceholder();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.radiusLg,
      onTap: () {
        Navigator.of(context)
            .push<double?>(
              MaterialPageRoute(
                builder: (_) => ExerciseDetailScreen(
                  exercise: exercise,
                  muscleNames: muscleNames,
                ),
              ),
            )
            .then((newRating) {
              if (newRating != null) {
                context.read<ExerciseCubit>().updateRating(
                  exercise.id,
                  newRating,
                );
              }
            });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
            // thumbnail bên trái
            _buildThumbnail(),
            SizedBox(width: 12.w),

            // nội dung bên phải
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // tên bài + chấm xanh
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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

                  // nhiều muscle
                  Text(
                    muscleNames.isEmpty ? '-' : muscleNames.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          label: 'Equipment',
                          value: exercise.equipment,
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
          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: 2.h),
        Text(
          value.isEmpty ? '-' : value,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}
