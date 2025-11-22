part of '../exercise_home_screen.dart';

class _FilterSheet extends StatefulWidget {
  final ExerciseHomeState state;

  const _FilterSheet({required this.state});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  // Selected filters
  Set<String> selectedBodyPartIds = {};
  Set<String> selectedEquipmentIds = {};
  Set<String> selectedMuscleIds = {};
  Set<String> selectedExerciseTypeIds = {};
  Set<String> selectedCategoryIds = {};
  LocationEnum? selectedLocation;

  @override
  void initState() {
    super.initState();
    // Initialize with current filters
    selectedEquipmentIds = Set.from(widget.state.activeEquipmentIds);
    selectedMuscleIds = Set.from(widget.state.activeMuscleIds);
    selectedExerciseTypeIds = Set.from(widget.state.activeExerciseTypeIds);
    selectedCategoryIds = Set.from(widget.state.activeCategoryIds);
    selectedLocation = widget.state.activeLocation;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = widget.state.status == ExerciseHomeStatus.loadingFilters;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: isLoading ? _buildSkeletonLoading() : _buildFilterContent(),
          ),

          // Footer with buttons
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location filter
          _buildLocationFilter(),
          SizedBox(height: AppSpacing.xl.h),

          // Equipment filter
          if (widget.state.equipments.isNotEmpty) ...[
            _buildSectionTitle('Equipment'),
            SizedBox(height: AppSpacing.md.h),
            _buildEquipmentFilter(),
            SizedBox(height: AppSpacing.xl.h),
          ],

          // Muscles filter
          if (widget.state.muscles.isNotEmpty) ...[
            _buildSectionTitle('Target Muscles'),
            SizedBox(height: AppSpacing.md.h),
            _buildMusclesFilter(),
            SizedBox(height: AppSpacing.xl.h),
          ],

          // Exercise Types filter
          if (widget.state.exerciseTypes.isNotEmpty) ...[
            _buildSectionTitle('Exercise Types'),
            SizedBox(height: AppSpacing.md.h),
            _buildExerciseTypesFilter(),
            SizedBox(height: AppSpacing.xl.h),
          ],

          // Categories filter
          if (widget.state.categories.isNotEmpty) ...[
            _buildSectionTitle('Categories'),
            SizedBox(height: AppSpacing.md.h),
            _buildCategoriesFilter(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Location'),
        SizedBox(height: AppSpacing.md.h),
        Wrap(
          spacing: AppSpacing.sm.w,
          runSpacing: AppSpacing.sm.h,
          children: LocationEnum.values.map((location) {
            final isSelected = selectedLocation == location;
            return FilterChip(
              label: Text(location.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedLocation = selected ? location : null;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEquipmentFilter() {
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: widget.state.equipments.map((equipment) {
        final isSelected = selectedEquipmentIds.contains(equipment.id);
        return FilterChip(
          label: Text(equipment.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedEquipmentIds.add(equipment.id);
              } else {
                selectedEquipmentIds.remove(equipment.id);
              }
            });
          },
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMusclesFilter() {
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: widget.state.muscles.map((muscle) {
        final isSelected = selectedMuscleIds.contains(muscle.id);
        return FilterChip(
          label: Text(muscle.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedMuscleIds.add(muscle.id);
              } else {
                selectedMuscleIds.remove(muscle.id);
              }
            });
          },
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseTypesFilter() {
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: widget.state.exerciseTypes.map((type) {
        final isSelected = selectedExerciseTypeIds.contains(type.id);
        return FilterChip(
          label: Text(type.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedExerciseTypeIds.add(type.id);
              } else {
                selectedExerciseTypeIds.remove(type.id);
              }
            });
          },
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesFilter() {
    return Wrap(
      spacing: AppSpacing.sm.w,
      runSpacing: AppSpacing.sm.h,
      children: widget.state.categories.map((category) {
        final isSelected = selectedCategoryIds.contains(category.id);
        return FilterChip(
          label: Text(category.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedCategoryIds.add(category.id);
              } else {
                selectedCategoryIds.remove(category.id);
              }
            });
          },
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    final hasFilters =
        selectedEquipmentIds.isNotEmpty ||
        selectedMuscleIds.isNotEmpty ||
        selectedExerciseTypeIds.isNotEmpty ||
        selectedCategoryIds.isNotEmpty ||
        selectedBodyPartIds.isNotEmpty ||
        selectedLocation != null;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          // Clear button
          if (hasFilters)
            Expanded(
              child: ButtonPrimary(
                variant: ButtonVariant.primaryOutline,
                title: 'Clear All',
                onPressed: () {
                  setState(() {
                    selectedEquipmentIds.clear();
                    selectedMuscleIds.clear();
                    selectedExerciseTypeIds.clear();
                    selectedCategoryIds.clear();
                    selectedBodyPartIds.clear();
                    selectedLocation = null;
                  });
                  context.read<ExerciseHomeBloc>().add(ClearFilters());
                },
              ),
            ),
          if (hasFilters) SizedBox(width: AppSpacing.md.w),

          // Apply button
          Expanded(
            flex: hasFilters ? 1 : 1,
            child: ButtonPrimary(
              variant: ButtonVariant.primarySolid,
              title: 'Apply Filters',
              onPressed: () {
                context.read<ExerciseHomeBloc>().add(
                  ApplyFilters(
                    location: selectedLocation,
                    equipmentIds: selectedEquipmentIds.toList(),
                    muscleIds: selectedMuscleIds.toList(),
                    exerciseTypeIds: selectedExerciseTypeIds.toList(),
                    categoryIds: selectedCategoryIds.toList(),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title skeleton
          const SkeletonLoading(
            variant: SkeletonVariant.line,
            width: 100,
            height: 20,
          ),
          SizedBox(height: AppSpacing.md.h),

          // Chips skeleton
          Wrap(
            spacing: AppSpacing.sm.w,
            runSpacing: AppSpacing.sm.h,
            children: List.generate(
              6,
              (index) => SkeletonLoading(
                variant: SkeletonVariant.button,
                width: 80 + (index * 10).toDouble(),
                height: 32,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xl.h),

          // Repeat for other sections
          ...List.generate(4, (sectionIndex) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLoading(
                  variant: SkeletonVariant.line,
                  width: 120,
                  height: 20,
                ),
                SizedBox(height: AppSpacing.md.h),
                Wrap(
                  spacing: AppSpacing.sm.w,
                  runSpacing: AppSpacing.sm.h,
                  children: List.generate(
                    5,
                    (index) => SkeletonLoading(
                      variant: SkeletonVariant.button,
                      width: 70 + (index * 15).toDouble(),
                      height: 32,
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
              ],
            );
          }),
        ],
      ),
    );
  }
}
