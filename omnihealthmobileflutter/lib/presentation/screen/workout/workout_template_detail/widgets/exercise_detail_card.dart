part of '../workout_template_detail_screen.dart';

class _ExerciseDetailCard extends StatelessWidget {
  final WorkoutTemplateDetailEntity exercise;
  final int index;

  const _ExerciseDetailCard({
    required this.exercise,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with index and exercise info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Index number
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Exercise image (if available)
              if (exercise.exerciseImageUrl != null &&
                  exercise.exerciseImageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    exercise.exerciseImageUrl!,
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: Colors.grey[400],
                          size: 24.sp,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.grey[400],
                    size: 24.sp,
                  ),
                ),

              SizedBox(width: 12.w),

              // Exercise name and type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor(exercise.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        exercise.type,
                        style: TextStyle(
                          color: _getTypeColor(exercise.type),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sets section
          if (exercise.sets.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Divider(height: 1, color: Colors.grey[200]),
            SizedBox(height: 12.h),

            // Sets header
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Set',
                    style: _headerStyle(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Reps/Thời gian',
                    style: _headerStyle(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Kg/Km',
                    style: _headerStyle(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Rest',
                    style: _headerStyle(context),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Sets rows
            ...exercise.sets.map((set) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          '${set.setOrder}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatRepsOrDuration(set),
                        style: _valueStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatWeightOrDistance(set),
                        style: _valueStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatRest(set),
                        style: _valueStyle(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'strength':
        return Colors.red;
      case 'cardio':
        return Colors.blue;
      case 'flexibility':
        return Colors.green;
      case 'balance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  TextStyle _headerStyle(BuildContext context) {
    return TextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
    );
  }

  TextStyle _valueStyle(BuildContext context) {
    return TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w500,
      color: Colors.grey[800],
    );
  }

  String _formatRepsOrDuration(WorkoutTemplateSetEntity set) {
    if (set.reps != null && set.reps! > 0) {
      return '${set.reps} reps';
    }
    if (set.duration != null && set.duration! > 0) {
      if (set.duration! >= 60) {
        final mins = set.duration! ~/ 60;
        final secs = set.duration! % 60;
        return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
      }
      return '${set.duration}s';
    }
    return '-';
  }

  String _formatWeightOrDistance(WorkoutTemplateSetEntity set) {
    if (set.weight != null && set.weight! > 0) {
      return '${set.weight} kg';
    }
    if (set.distance != null && set.distance! > 0) {
      if (set.distance! >= 1000) {
        return '${(set.distance! / 1000).toStringAsFixed(1)} km';
      }
      return '${set.distance!.toInt()} m';
    }
    return '-';
  }

  String _formatRest(WorkoutTemplateSetEntity set) {
    if (set.restAfterSetSeconds != null && set.restAfterSetSeconds! > 0) {
      if (set.restAfterSetSeconds! >= 60) {
        final mins = set.restAfterSetSeconds! ~/ 60;
        final secs = set.restAfterSetSeconds! % 60;
        return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
      }
      return '${set.restAfterSetSeconds}s';
    }
    return '-';
  }
}

