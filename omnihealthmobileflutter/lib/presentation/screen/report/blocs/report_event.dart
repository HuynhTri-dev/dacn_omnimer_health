import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Load initial workout logs data
class LoadWorkoutLogs extends ReportEvent {
  const LoadWorkoutLogs();
}

/// Refresh workout logs data
class RefreshWorkoutLogs extends ReportEvent {
  const RefreshWorkoutLogs();
}

/// Delete a workout log
class DeleteWorkoutLog extends ReportEvent {
  final String logId;

  const DeleteWorkoutLog(this.logId);

  @override
  List<Object?> get props => [logId];
}

/// Load chart data (calories burned, muscle distribution, goal progress, weight progress)
class LoadChartData extends ReportEvent {
  const LoadChartData();
}

