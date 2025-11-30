part of '../workout_template_form_screen.dart';

class _ExerciseItem extends StatelessWidget {
  final WorkoutExerciseFormData exercise;
  final int exerciseIndex;
  final VoidCallback onRemove;

  const _ExerciseItem({
    required this.exercise,
    required this.exerciseIndex,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Row(
            children: [
              // Exercise Image
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                clipBehavior: Clip.antiAlias,
                child:
                    exercise.exerciseImageUrl != null &&
                        exercise.exerciseImageUrl!.isNotEmpty
                    ? Image.network(
                        exercise.exerciseImageUrl!,
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
                                value:
                                    loadingProgress.expectedTotalBytes != null
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

              // Exercise Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${exercise.sets.length} sets',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Type badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _getTypeLabel(exercise.type),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Delete Button
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 20.sp,
                ),
                onPressed: () => _showDeleteConfirmation(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Divider
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),

          SizedBox(height: 12.h),

          // Sets Header - Dynamic based on type
          _buildSetsHeader(context),

          SizedBox(height: 8.h),

          // Sets List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercise.sets.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, setIndex) {
              final set = exercise.sets[setIndex];
              return _SetRow(
                set: set,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
                exerciseType: exercise.type,
              );
            },
          ),

          SizedBox(height: 12.h),

          // Add/Remove Set Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<WorkoutTemplateFormCubit>().addSet(
                      exerciseIndex,
                    );
                  },
                  icon: Icon(Icons.add, size: 16.sp),
                  label: Text('Add Set', style: TextStyle(fontSize: 12.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),

              if (exercise.sets.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: exercise.sets.length > 1
                        ? () {
                            context.read<WorkoutTemplateFormCubit>().removeSet(
                              exerciseIndex,
                              exercise.sets.length - 1,
                            );
                          }
                        : null,
                    icon: Icon(Icons.remove, size: 16.sp),
                    label: Text(
                      'Remove Set',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[400],
                      side: BorderSide(
                        color: exercise.sets.length > 1
                            ? Colors.red.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'reps':
        return 'Reps';
      case 'time':
        return 'Time';
      case 'distance':
        return 'Distance';
      case 'mixed':
        return 'Mixed';
      default:
        return 'Reps';
    }
  }

  Widget _buildSetsHeader(BuildContext context) {
    final headerStyle = TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
      color: Colors.grey[500],
    );

    switch (exercise.type) {
      case 'reps':
        return Row(
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: Text('SET', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('WEIGHT', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('REPS', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('REST', style: headerStyle)),
            ),
            SizedBox(width: 32.w),
          ],
        );
      case 'time':
        return Row(
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: Text('SET', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('REPS', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('DURATION', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('REST', style: headerStyle)),
            ),
            SizedBox(width: 32.w),
          ],
        );
      case 'distance':
        return Row(
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: Text('SET', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 2,
              child: Center(child: Text('DISTANCE', style: headerStyle)),
            ),
            SizedBox(width: 32.w),
          ],
        );
      case 'mixed':
        // Mixed type has its own labeled fields, no header needed
        return Row(
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: Text('SET', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(
                child: Text(
                  'CUSTOM FIELDS',
                  style: headerStyle,
                ),
              ),
            ),
            SizedBox(width: 32.w),
          ],
        );
      default:
        return Row(
          children: [
            SizedBox(
              width: 36.w,
              child: Center(child: Text('SET', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('WEIGHT', style: headerStyle)),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Center(child: Text('REPS', style: headerStyle)),
            ),
            SizedBox(width: 32.w),
          ],
        );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Exercise'),
        content: Text(
          'Are you sure you want to remove "${exercise.exerciseName}" from template?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onRemove();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
