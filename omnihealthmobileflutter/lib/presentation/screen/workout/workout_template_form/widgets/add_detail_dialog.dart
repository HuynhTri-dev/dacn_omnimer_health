part of '../workout_template_form_screen.dart';

class _AddDetailDialog extends StatefulWidget {
  const _AddDetailDialog();

  @override
  State<_AddDetailDialog> createState() => _AddDetailDialogState();
}

class _AddDetailDialogState extends State<_AddDetailDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  String? _selectedLocation;

  // Selected IDs
  List<String> _selectedBodyPartIds = [];
  List<String> _selectedEquipmentIds = [];
  List<String> _selectedExerciseCategoryIds = [];
  List<String> _selectedExerciseTypeIds = [];
  List<String> _selectedMuscleIds = [];

  // Backend expects PascalCase enum values
  final List<String> _locations = ['Gym', 'Home', 'Outdoor', 'Pool', 'None'];

  @override
  void initState() {
    super.initState();
    final state = context.read<WorkoutTemplateFormCubit>().state;
    _descriptionController = TextEditingController(text: state.description);
    _notesController = TextEditingController(text: state.notes ?? '');
    _selectedLocation = state.location;

    // Initialize selected IDs from current state
    _selectedBodyPartIds = List.from(state.bodyPartIds);
    _selectedEquipmentIds = List.from(state.equipmentIds);
    _selectedExerciseCategoryIds = List.from(state.exerciseCategoryIds);
    _selectedExerciseTypeIds = List.from(state.exerciseTypeIds);
    _selectedMuscleIds = List.from(state.muscleIds);

    // Load data
    context.read<TemplateDetailsCubit>().loadAllData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getLocationLabel(String location) {
    switch (location) {
      case 'Gym':
        return 'Gym';
      case 'Home':
        return 'Home';
      case 'Outdoor':
        return 'Outdoor';
      case 'Pool':
        return 'Pool';
      case 'None':
        return 'Not specified';
      default:
        return location;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: Colors.white, size: 24.sp),
                  SizedBox(width: 12.w),
                  Text(
                    'Template Details',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: BlocBuilder<TemplateDetailsCubit, TemplateDetailsState>(
                builder: (context, detailsState) {
                  if (detailsState.status == TemplateDetailsStatus.loading) {
                    return Padding(
                      padding: EdgeInsets.all(40.w),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description
                        _buildSectionTitle('Description'),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _descriptionController,
                          decoration: _inputDecoration('Enter template description'),
                          maxLines: 2,
                        ),

                        SizedBox(height: 16.h),

                        // Notes
                        _buildSectionTitle('Notes'),
                        SizedBox(height: 8.h),
                        TextField(
                          controller: _notesController,
                          decoration: _inputDecoration('Enter notes (optional)'),
                          maxLines: 2,
                        ),

                        SizedBox(height: 16.h),

                        // Location
                        _buildSectionTitle('Location'),
                        SizedBox(height: 8.h),
                        DropdownButtonFormField<String>(
                          value: _selectedLocation,
                          decoration: _inputDecoration('Select location'),
                          items: _locations.map((location) {
                            return DropdownMenuItem(
                              value: location,
                              child: Text(_getLocationLabel(location)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLocation = value;
                            });
                          },
                        ),

                        SizedBox(height: 20.h),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 12.h),

                        // Body Parts
                        _buildMultiSelectSection(
                          title: 'Target Body Parts',
                          icon: Icons.accessibility_new,
                          items: detailsState.bodyParts,
                          selectedIds: _selectedBodyPartIds,
                          getId: (item) => item.id,
                          getName: (item) => item.name,
                          onToggle: (id) {
                            setState(() {
                              if (_selectedBodyPartIds.contains(id)) {
                                _selectedBodyPartIds.remove(id);
                              } else {
                                _selectedBodyPartIds.add(id);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Equipments
                        _buildMultiSelectSection(
                          title: 'Equipment',
                          icon: Icons.sports_gymnastics,
                          items: detailsState.equipments,
                          selectedIds: _selectedEquipmentIds,
                          getId: (item) => item.id,
                          getName: (item) => item.name,
                          onToggle: (id) {
                            setState(() {
                              if (_selectedEquipmentIds.contains(id)) {
                                _selectedEquipmentIds.remove(id);
                              } else {
                                _selectedEquipmentIds.add(id);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Exercise Types
                        _buildMultiSelectSection(
                          title: 'Exercise Types',
                          icon: Icons.category,
                          items: detailsState.exerciseTypes,
                          selectedIds: _selectedExerciseTypeIds,
                          getId: (item) => item.id,
                          getName: (item) => item.name,
                          onToggle: (id) {
                            setState(() {
                              if (_selectedExerciseTypeIds.contains(id)) {
                                _selectedExerciseTypeIds.remove(id);
                              } else {
                                _selectedExerciseTypeIds.add(id);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Exercise Categories
                        _buildMultiSelectSection(
                          title: 'Categories',
                          icon: Icons.label,
                          items: detailsState.exerciseCategories,
                          selectedIds: _selectedExerciseCategoryIds,
                          getId: (item) => item.id,
                          getName: (item) => item.name,
                          onToggle: (id) {
                            setState(() {
                              if (_selectedExerciseCategoryIds.contains(id)) {
                                _selectedExerciseCategoryIds.remove(id);
                              } else {
                                _selectedExerciseCategoryIds.add(id);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),

                        // Muscles
                        _buildMultiSelectSection(
                          title: 'Target Muscles',
                          icon: Icons.fitness_center,
                          items: detailsState.muscles,
                          selectedIds: _selectedMuscleIds,
                          getId: (item) => item.id,
                          getName: (item) => item.name,
                          onToggle: (id) {
                            setState(() {
                              if (_selectedMuscleIds.contains(id)) {
                                _selectedMuscleIds.remove(id);
                              } else {
                                _selectedMuscleIds.add(id);
                              }
                            });
                          },
                        ),

                        SizedBox(height: 16.h),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(16.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      contentPadding: EdgeInsets.all(12.w),
    );
  }

  Widget _buildMultiSelectSection<T>({
    required String title,
    required IconData icon,
    required List<T> items,
    required List<String> selectedIds,
    required String Function(T) getId,
    required String Function(T) getName,
    required void Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18.sp, color: Theme.of(context).primaryColor),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (selectedIds.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${selectedIds.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),
        if (items.isEmpty)
          Text(
            'No items available',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: items.map((item) {
              final id = getId(item);
              final name = getName(item);
              final isSelected = selectedIds.contains(id);

              return InkWell(
                onTap: () => onToggle(id),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check,
                          size: 14.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _saveDetails() {
    context.read<WorkoutTemplateFormCubit>().updateDetails(
          description: _descriptionController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          location: _selectedLocation,
          bodyPartIds: _selectedBodyPartIds,
          equipmentIds: _selectedEquipmentIds,
          exerciseTypeIds: _selectedExerciseTypeIds,
          exerciseCategoryIds: _selectedExerciseCategoryIds,
          muscleIds: _selectedMuscleIds,
        );
    Navigator.of(context).pop();
  }
}
