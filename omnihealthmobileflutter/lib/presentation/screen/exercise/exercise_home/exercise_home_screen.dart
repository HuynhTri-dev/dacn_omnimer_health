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

class _BodyAndMuscleHeader extends StatelessWidget {
  final MuscleModel? selectedMuscle;

  const _BodyAndMuscleHeader({required this.selectedMuscle});

  @override
  Widget build(BuildContext context) {
    final muscle = selectedMuscle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hình người 3D bên trái
        Expanded(
          flex: 3,
          child: Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.accessibility_new,
              size: 120.r,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Card Muscle bên phải
        Expanded(
          flex: 2,
          child: Container(
            height: 220.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  muscle?.name.isNotEmpty == true
                      ? muscle!.name
                      : 'Muscle Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  muscle?.description.isNotEmpty == true
                      ? muscle!.description
                      : 'Description...',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: AppRadius.radiusLg,
                  child: (muscle != null && muscle.image.isNotEmpty)
                      ? Image.network(
                          muscle.image,
                          height: 90.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 90.h,
                          width: double.infinity,
                          color: AppColors.background,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int resultCount;
  final VoidCallback onPressed;

  const _FilterButton({required this.resultCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 20, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              '$resultCount',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bài tập...',
        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

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
  final MuscleModel? mainMuscle; // 👈 thêm
  final List<String> muscleNames; // 👈 thêm

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
        // ✅ Mang theo ExerciseCubit sang màn chi tiết
        final exerciseCubit = context.read<ExerciseCubit>();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: exerciseCubit,
              child: ExerciseDetailScreen(
                exercise: exercise,
                muscleNames: muscleNames,
              ),
            ),
          ),
        );
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

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ExerciseFilterSheet extends StatefulWidget {
  final List<ExerciseModel> exercises;
  final List<MuscleModel> muscles;
  final ExerciseFilter initial;

  const _ExerciseFilterSheet({
    required this.exercises,
    required this.muscles,
    required this.initial,
  });

  @override
  State<_ExerciseFilterSheet> createState() => _ExerciseFilterSheetState();
}

class _ExerciseFilterSheetState extends State<_ExerciseFilterSheet> {
  late Set<String> _equipment;
  late Set<String> _muscles;
  late Set<String> _types;
  late Set<String> _categories;
  late Set<String> _locations;

  @override
  void initState() {
    super.initState();
    _equipment = {...widget.initial.equipmentIds};
    _muscles = {...widget.initial.muscleIds};
    _types = {...widget.initial.exerciseTypes};
    _categories = {...widget.initial.exerciseCategories};
    _locations = {...widget.initial.locations};
  }

  @override
  Widget build(BuildContext context) {
    // tập hợp các giá trị có trong danh sách bài tập
    final allEquipment =
        widget.exercises
            .map((e) => e.equipment)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final allTypes =
        widget.exercises
            .map((e) => e.type)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final allCategories =
        widget.exercises
            .map((e) => e.category)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final allLocations =
        widget.exercises
            .map((e) => e.location)
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    // map id -> name cho muscles, CHỈ hiển thị tên – không hiển thị id
    final muscleMap = {for (final m in widget.muscles) m.id: m.name};
    final allMuscles = muscleMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        bottom: 16.h + MediaQuery.of(context).viewInsets.bottom,
        top: 8.h,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: AppRadius.radiusSm,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Filter exercises',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterSection(
                      title: 'Muscles',
                      children: allMuscles
                          .map(
                            (entry) => _FilterPill(
                              label: entry.value,
                              selected: _muscles.contains(entry.key),
                              onTap: () {
                                setState(() {
                                  if (_muscles.contains(entry.key)) {
                                    _muscles.remove(entry.key);
                                  } else {
                                    _muscles.add(entry.key);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    _FilterSection(
                      title: 'Equipment',
                      children: allEquipment
                          .map(
                            (item) => _FilterPill(
                              label: item,
                              selected: _equipment.contains(item),
                              onTap: () {
                                setState(() {
                                  if (_equipment.contains(item)) {
                                    _equipment.remove(item);
                                  } else {
                                    _equipment.add(item);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    _FilterSection(
                      title: 'Type',
                      children: allTypes
                          .map(
                            (item) => _FilterPill(
                              label: item,
                              selected: _types.contains(item),
                              onTap: () {
                                setState(() {
                                  if (_types.contains(item)) {
                                    _types.remove(item);
                                  } else {
                                    _types.add(item);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    _FilterSection(
                      title: 'Category',
                      children: allCategories
                          .map(
                            (item) => _FilterPill(
                              label: item,
                              selected: _categories.contains(item),
                              onTap: () {
                                setState(() {
                                  if (_categories.contains(item)) {
                                    _categories.remove(item);
                                  } else {
                                    _categories.add(item);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    _FilterSection(
                      title: 'Location',
                      children: allLocations
                          .map(
                            (item) => _FilterPill(
                              label: item,
                              selected: _locations.contains(item),
                              onTap: () {
                                setState(() {
                                  if (_locations.contains(item)) {
                                    _locations.remove(item);
                                  } else {
                                    _locations.add(item);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(const ExerciseFilter());
                    },
                    child: Text(
                      'Reset',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusLg,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(
                        ExerciseFilter(
                          equipmentIds: _equipment,
                          muscleIds: _muscles,
                          exerciseTypes: _types,
                          exerciseCategories: _categories,
                          locations: _locations,
                        ),
                      );
                    },
                    child: Text(
                      'Apply',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _FilterSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(spacing: 8.w, runSpacing: 8.h, children: children),
        ],
      ),
    );
  }
}
