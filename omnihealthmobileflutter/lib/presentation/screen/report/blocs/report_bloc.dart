import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/base_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_logs_usecase.dart';
import 'package:omnihealthmobileflutter/utils/logger.dart';

import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetWorkoutLogsUseCase getWorkoutLogsUseCase;
  final WorkoutLogRepositoryAbs workoutLogRepository;

  ReportBloc({
    required this.getWorkoutLogsUseCase,
    required this.workoutLogRepository,
  }) : super(const ReportState()) {
    on<LoadWorkoutLogs>(_onLoadWorkoutLogs);
    on<RefreshWorkoutLogs>(_onRefreshWorkoutLogs);
    on<DeleteWorkoutLog>(_onDeleteWorkoutLog);
  }

  Future<void> _onLoadWorkoutLogs(
    LoadWorkoutLogs event,
    Emitter<ReportState> emit,
  ) async {
    logger.i('[ReportBloc] _onLoadWorkoutLogs called');
    emit(state.copyWith(status: ReportStatus.loading));

    try {
      final response = await getWorkoutLogsUseCase(NoParams());

      if (response.success && response.data != null) {
        // Sort by startedAt descending (newest first)
        final sortedLogs = List.of(response.data!)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        emit(state.copyWith(
          status: ReportStatus.loaded,
          workoutLogs: sortedLogs,
        ));
        logger.i('[ReportBloc] Loaded ${sortedLogs.length} workout logs');
      } else {
        emit(state.copyWith(
          status: ReportStatus.error,
          errorMessage: response.message.isNotEmpty 
              ? response.message 
              : 'Failed to load workout logs',
        ));
      }
    } catch (e) {
      logger.e('[ReportBloc] Error loading workout logs: $e');
      emit(state.copyWith(
        status: ReportStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshWorkoutLogs(
    RefreshWorkoutLogs event,
    Emitter<ReportState> emit,
  ) async {
    logger.i('[ReportBloc] _onRefreshWorkoutLogs called');

    try {
      final response = await getWorkoutLogsUseCase(NoParams());

      if (response.success && response.data != null) {
        final sortedLogs = List.of(response.data!)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

        emit(state.copyWith(
          status: ReportStatus.loaded,
          workoutLogs: sortedLogs,
        ));
      }
    } catch (e) {
      logger.e('[ReportBloc] Error refreshing workout logs: $e');
      // Keep current data on refresh error
    }
  }

  Future<void> _onDeleteWorkoutLog(
    DeleteWorkoutLog event,
    Emitter<ReportState> emit,
  ) async {
    logger.i('[ReportBloc] _onDeleteWorkoutLog called: ${event.logId}');

    try {
      final response = await workoutLogRepository.deleteWorkoutLog(event.logId);

      if (response.success) {
        // Remove the deleted log from the list
        final updatedLogs = state.workoutLogs
            .where((log) => log.id != event.logId)
            .toList();

        emit(state.copyWith(workoutLogs: updatedLogs));
        logger.i('[ReportBloc] Successfully deleted workout log');
      } else {
        emit(state.copyWith(
          errorMessage: response.message.isNotEmpty 
              ? response.message 
              : 'Failed to delete workout log',
        ));
      }
    } catch (e) {
      logger.e('[ReportBloc] Error deleting workout log: $e');
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}

