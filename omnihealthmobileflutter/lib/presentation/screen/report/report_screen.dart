import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_log_summary_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/auth/user_header_widget.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/charts_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/empty_workout_history.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/summary_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/workout_log_card.dart';

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
                            'Error: ${state.errorMessage ?? "Unknown error"}',
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
                        vertical: 12.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            'Workout Report',
                            style: theme.textTheme.displayMedium,
                          ),
                          SizedBox(height: 12.h),

                          // Summary Cards
                          SummarySection(state: state),

                          SizedBox(height: 16.h),

                          // Charts Section
                          ChartsSection(state: state),

                          SizedBox(height: 16.h),

                          // Workout History Title
                          Text(
                            'Workout History',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Workout Logs List
                          if (state.workoutLogs.isEmpty)
                            const EmptyWorkoutHistory()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.workoutLogs.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final log = state.workoutLogs[index];
                                return WorkoutLogCard(
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

  void _showDeleteConfirmation(
    BuildContext context,
    WorkoutLogSummaryEntity log,
  ) {
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
