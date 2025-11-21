// lib/presentation/screen/exercise/exercise_home/widgets/filter_sheet.dart
part of '../exercise_home_screen.dart';

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
