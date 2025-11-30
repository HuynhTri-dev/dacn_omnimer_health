import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/calories_burned_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/weight_progress_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ReportView();
  }
}

class _ReportView extends StatefulWidget {
  const _ReportView();

  @override
  State<_ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<_ReportView> {
  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(const LoadWorkoutLogs());
    context.read<ReportBloc>().add(const LoadChartData());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const UserHeaderWidget(),
            Expanded(
              child: BlocBuilder<ReportBloc, ReportState>(
                builder: (context, state) {
                  if (state.status == ReportStatus.loading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading workout history...'),
                        ],
                      ),
                    );
                  }

                  if (state.status == ReportStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: theme.colorScheme.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            state.errorMessage ?? 'An error occurred',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ReportBloc>().add(
                                const LoadWorkoutLogs(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ReportBloc>().add(
                        const RefreshWorkoutLogs(),
                      );
                      context.read<ReportBloc>().add(const LoadChartData());
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Workout Report',
                            style: theme.textTheme.displayMedium,
                          ),
                          SizedBox(height: 16.h),

                          // Summary Cards
                          _SummarySection(state: state),

                          SizedBox(height: 24.h),

                          // Charts Section
                          _ChartsSection(state: state),

                          SizedBox(height: 24.h),

                          // Workout History Title
                          Text(
                            'Workout History',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          // Workout Logs List
                          if (state.workoutLogs.isEmpty)
                            _EmptyWorkoutHistory()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.workoutLogs.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final log = state.workoutLogs[index];
                                return _WorkoutLogCard(
                                  log: log,
                                  onDelete: () {
                                    _showDeleteConfirmation(context, log);
                                  },
                                );
                              },
                            ),
                        ],
                      ),
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

  void _showDeleteConfirmation(BuildContext context, WorkoutLogEntity log) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Workout Log'),
        content: Text('Are you sure you want to delete "${log.workoutName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (log.id != null) {
                context.read<ReportBloc>().add(DeleteWorkoutLog(log.id!));
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final ReportState state;

  const _SummarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor.withOpacity(0.8), theme.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.fitness_center,
                  title: 'Workouts',
                  value: state.totalWorkouts.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.timer,
                  title: 'Total Time',
                  value: state.formattedTotalDuration,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.repeat,
                  title: 'Sets',
                  value: state.totalSetsCompleted.toString(),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.sports_gymnastics,
                  title: 'Exercises',
                  value: state.totalExercisesCompleted.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyWorkoutHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.history, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No workout history yet',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete your first workout to see it here',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutLogCard extends StatelessWidget {
  final WorkoutLogEntity log;
  final VoidCallback onDelete;

  const _WorkoutLogCard({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Determine status color
    Color statusColor;
    switch (log.status) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            _showWorkoutDetails(context);
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        log.workoutName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        log.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Date and time
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      dateFormat.format(log.startedAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 16.w),
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      timeFormat.format(log.startedAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatItem(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: log.formattedDuration,
                    ),
                    _StatItem(
                      icon: Icons.sports_gymnastics,
                      label: 'Exercises',
                      value: '${log.totalExercisesCount}',
                    ),
                    _StatItem(
                      icon: Icons.repeat,
                      label: 'Sets',
                      value: '${log.totalSets}',
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 20.sp,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy • HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
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

              // Header with title and close button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.workoutName.isNotEmpty
                                ? log.workoutName
                                : 'Workout Session',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            dateFormat.format(log.startedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),
              ),

              // Summary Cards
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor.withOpacity(0.8),
                      theme.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailSummaryItem(
                      icon: Icons.timer,
                      value: log.formattedDuration,
                      label: 'Duration',
                    ),
                    _DetailSummaryItem(
                      icon: Icons.fitness_center,
                      value: '${log.totalExercisesCount}',
                      label: 'Exercises',
                    ),
                    _DetailSummaryItem(
                      icon: Icons.repeat,
                      value: '${log.totalSets}',
                      label: 'Sets',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Section Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 20.sp,
                      color: theme.primaryColor,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Exercise Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${log.exercises.length} exercises',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Exercises list
              Expanded(
                child: log.exercises.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center_outlined,
                              size: 64.sp,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No exercise details available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Exercise data will appear here after workouts',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: log.exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = log.exercises[index];
                          return _ExerciseDetailCard(
                            exercise: exercise,
                            index: index + 1,
                            theme: theme,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ExerciseDetailCard({
    required WorkoutLogExerciseEntity exercise,
    required int index,
    required ThemeData theme,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Row(
              children: [
                // Index badge
                Container(
                  width: 28.w,
                  height: 28.w,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Exercise name and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName.isNotEmpty
                            ? exercise.exerciseName
                            : 'Exercise $index',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (exercise.type.isNotEmpty)
                        Text(
                          exercise.type.replaceAll('_', ' ').toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                    ],
                  ),
                ),
                // Sets count badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.repeat,
                        color: theme.primaryColor,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${exercise.totalSetsCount} sets',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sets
          if (exercise.sets.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sets',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ...exercise.sets.asMap().entries.map((entry) {
                    final setIndex = entry.key;
                    final set = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 6.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          // Set number
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${setIndex + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Set details
                          Expanded(
                            child: Text(
                              _formatSetInfo(set),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: theme.textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Text(
                'No set data available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatSetInfo(WorkoutLogSetEntity set) {
    final parts = <String>[];

    if (set.reps != null) {
      parts.add('${set.reps} reps');
    }
    if (set.weight != null) {
      parts.add('${set.weight}kg');
    }
    if (set.duration != null) {
      parts.add('${set.duration}s');
    }
    if (set.distance != null) {
      parts.add('${set.distance}m');
    }

    if (parts.isEmpty) {
      return 'Set ${set.setOrder}';
    }

    return parts.join(' × ');
  }
}

class _DetailSummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DetailSummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: Colors.white),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10.sp,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 18.sp, color: theme.primaryColor),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}

// =====================================================
// Charts Section
// =====================================================

class _ChartsSection extends StatelessWidget {
  final ReportState state;

  const _ChartsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isChartLoading) {
      return Container(
        padding: EdgeInsets.all(32.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        // Calories Burned Chart (needs at least 2 data points for line chart)
        if (state.caloriesBurned.length >= 2)
          _CaloriesBurnedChart(data: state.caloriesBurned)
        else
          _EmptyChartPlaceholder(title: 'Calories Burned'),

        SizedBox(height: 16.h),

        // Weight Progress Chart (needs at least 2 data points for line chart)
        if (state.weightProgress.length >= 2)
          _WeightProgressChart(data: state.weightProgress)
        else
          _EmptyChartPlaceholder(title: 'Weight Progress'),

        SizedBox(height: 16.h),

        // Two charts in a row
        Row(
          children: [
            // Muscle Distribution Chart (needs at least one non-zero count)
            Expanded(
              child:
                  state.muscleDistribution.isNotEmpty &&
                      state.muscleDistribution.any((m) => m.count > 0)
                  ? _MuscleDistributionChart(data: state.muscleDistribution)
                  : _EmptyChartPlaceholder(title: 'Muscle Distribution'),
            ),
            SizedBox(width: 12.w),
            // Goal Progress Chart (needs at least one non-zero count)
            Expanded(
              child:
                  state.goalProgress.isNotEmpty &&
                      state.goalProgress.any((g) => g.count > 0)
                  ? _GoalProgressChart(data: state.goalProgress)
                  : _EmptyChartPlaceholder(title: 'Goal Progress'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyChartPlaceholder extends StatelessWidget {
  final String title;

  const _EmptyChartPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Icon(
            Icons.show_chart,
            size: 48.sp,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 8.h),
          Text(
            'No data available',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Calories Burned Line Chart
// =====================================================

class _CaloriesBurnedChart extends StatelessWidget {
  final List<CaloriesBurnedEntity> data;

  const _CaloriesBurnedChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedData = List<CaloriesBurnedEntity>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Take last 7 days
    final displayData = sortedData.length > 7
        ? sortedData.sublist(sortedData.length - 7)
        : sortedData;

    final maxCalories = displayData
        .map((e) => e.calories)
        .reduce((a, b) => a > b ? a : b)
        .clamp(100.0, double.infinity);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Calories Burned',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14.sp,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Last 7 days',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 180.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxCalories / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayData.length) {
                          return const SizedBox.shrink();
                        }
                        final date = displayData[index].date;
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.sp,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxCalories / 4,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.sp,
                            fontFamily: 'Montserrat',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (displayData.length - 1).toDouble(),
                minY: 0,
                maxY: maxCalories,
                lineBarsData: [
                  LineChartBarData(
                    spots: displayData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.calories);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade400,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.orange,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.orange.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Weight Progress Line Chart
// =====================================================

class _WeightProgressChart extends StatelessWidget {
  final List<WeightProgressEntity> data;

  const _WeightProgressChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedData = List<WeightProgressEntity>.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Take last 10 data points
    final displayData = sortedData.length > 10
        ? sortedData.sublist(sortedData.length - 10)
        : sortedData;

    final weights = displayData.map((e) => e.weight).toList();
    final minWeight = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxWeight = weights.reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Progress',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.monitor_weight, size: 14.sp, color: Colors.blue),
                    SizedBox(width: 4.w),
                    Text(
                      '${displayData.last.weight.toStringAsFixed(1)} kg',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 180.h,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxWeight - minWeight) / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayData.length) {
                          return const SizedBox.shrink();
                        }
                        final date = displayData[index].date;
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            DateFormat('d/M').format(date),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 9.sp,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxWeight - minWeight) / 4,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10.sp,
                            fontFamily: 'Montserrat',
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (displayData.length - 1).toDouble(),
                minY: minWeight,
                maxY: maxWeight,
                lineBarsData: [
                  LineChartBarData(
                    spots: displayData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.weight);
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.indigo.shade400],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blue,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.3),
                          Colors.blue.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Muscle Distribution Pie Chart
// =====================================================

class _MuscleDistributionChart extends StatelessWidget {
  final List<MuscleDistributionEntity> data;

  const _MuscleDistributionChart({required this.data});

  static const List<Color> _chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out zero counts, sort by count and take top 5
    final filteredData = data.where((item) => item.count > 0).toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final displayData = filteredData.take(5).toList();
    final totalCount = displayData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Muscle Groups',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 25.r,
                sections: displayData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final percentage = totalCount > 0
                      ? (item.count / totalCount * 100)
                      : 0.0;

                  return PieChartSectionData(
                    color: _chartColors[index % _chartColors.length],
                    value: item.count.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 35.r,
                    titleStyle: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Legend
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: displayData.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _chartColors[index % _chartColors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    item.muscleName,
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// Goal Progress Pie Chart
// =====================================================

class _GoalProgressChart extends StatelessWidget {
  final List<GoalProgressEntity> data;

  const _GoalProgressChart({required this.data});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E); // Green
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF3B82F6); // Blue
      case 'not_started':
      case 'not started':
        return const Color(0xFF9CA3AF); // Gray
      case 'cancelled':
      case 'failed':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out zero count items for pie chart
    final filteredData = data.where((item) => item.count > 0).toList();
    final totalCount = filteredData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 25.r,
                sections: filteredData.map((item) {
                  final percentage = totalCount > 0
                      ? (item.count / totalCount * 100)
                      : 0.0;

                  return PieChartSectionData(
                    color: _getStatusColor(item.status),
                    value: item.count.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 35.r,
                    titleStyle: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Legend
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: filteredData.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatStatus(item.status),
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
