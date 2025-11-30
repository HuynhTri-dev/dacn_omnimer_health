import 'package:equatable/equatable.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';

enum WorkoutTemplateDetailStatus { initial, loading, loaded, error, deleting, deleted }

class WorkoutTemplateDetailState extends Equatable {
  final WorkoutTemplateDetailStatus status;
  final WorkoutTemplateEntity? template;
  final String? errorMessage;

  const WorkoutTemplateDetailState({
    this.status = WorkoutTemplateDetailStatus.initial,
    this.template,
    this.errorMessage,
  });

  WorkoutTemplateDetailState copyWith({
    WorkoutTemplateDetailStatus? status,
    WorkoutTemplateEntity? template,
    String? errorMessage,
  }) {
    return WorkoutTemplateDetailState(
      status: status ?? this.status,
      template: template ?? this.template,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, template, errorMessage];
}

