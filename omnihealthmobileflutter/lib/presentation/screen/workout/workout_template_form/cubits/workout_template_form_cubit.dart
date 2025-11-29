import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_template_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/create_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/update_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/entities/exercise/exercise_list_entity.dart';
import 'workout_template_form_state.dart';

class WorkoutTemplateFormCubit extends Cubit<WorkoutTemplateFormState> {
  final GetWorkoutTemplateByIdUseCase? getWorkoutTemplateByIdUseCase;
  final CreateWorkoutTemplateUseCase createWorkoutTemplateUseCase;
  final UpdateWorkoutTemplateUseCase updateWorkoutTemplateUseCase;

  WorkoutTemplateFormCubit({
    this.getWorkoutTemplateByIdUseCase,
    required this.createWorkoutTemplateUseCase,
    required this.updateWorkoutTemplateUseCase,
  }) : super(const WorkoutTemplateFormState());

  /// Initialize form for creating new template
  void initializeForCreate() {
    emit(
      const WorkoutTemplateFormState(
        status: WorkoutTemplateFormStatus.editing,
        name: 'Name Work',
        isEditMode: false,
      ),
    );
  }

  /// Initialize form for editing existing template
  Future<void> initializeForEdit(String templateId) async {
    if (getWorkoutTemplateByIdUseCase == null) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: 'UseCase not initialized',
        ),
      );
      return;
    }

    emit(state.copyWith(status: WorkoutTemplateFormStatus.loading));

    try {
      final response = await getWorkoutTemplateByIdUseCase!(templateId);

      if (response.success && response.data != null) {
        final template = response.data!;

        // Convert template to form data
        final exercises = template.workOutDetail.map((detail) {
          return WorkoutExerciseFormData(
            exerciseId: detail.exerciseId,
            exerciseName: detail.exerciseName,
            exerciseImageUrl: detail.exerciseImageUrl,
            type: detail.type,
            sets: detail.sets.map((set) {
              return WorkoutSetFormData(
                setOrder: set.setOrder,
                reps: set.reps,
                weight: set.weight,
                duration: set.duration,
                distance: set.distance,
                restAfterSetSeconds: set.restAfterSetSeconds,
                notes: set.notes,
              );
            }).toList(),
          );
        }).toList();

        emit(
          WorkoutTemplateFormState(
            status: WorkoutTemplateFormStatus.editing,
            templateId: template.id,
            name: template.name,
            description: template.description,
            notes: template.notes,
            equipmentIds: template.equipments.map((e) => e.id).toList(),
            bodyPartIds: template.bodyPartsTarget.map((bp) => bp.id).toList(),
            exerciseTypeIds: template.exerciseTypes.map((et) => et.id).toList(),
            exerciseCategoryIds: template.exerciseCategories
                .map((ec) => ec.id)
                .toList(),
            muscleIds: template.musclesTarget.map((m) => m.id).toList(),
            location: template.location,
            exercises: exercises,
            isEditMode: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: WorkoutTemplateFormStatus.error,
            errorMessage: response.message ?? 'Failed to load template',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Update template name
  void updateName(String name) {
    emit(state.copyWith(name: name));
  }

  /// Update template details
  void updateDetails({
    String? description,
    String? notes,
    List<String>? equipmentIds,
    List<String>? bodyPartIds,
    List<String>? exerciseTypeIds,
    List<String>? exerciseCategoryIds,
    List<String>? muscleIds,
    String? location,
  }) {
    emit(
      state.copyWith(
        description: description ?? state.description,
        notes: notes,
        equipmentIds: equipmentIds ?? state.equipmentIds,
        bodyPartIds: bodyPartIds ?? state.bodyPartIds,
        exerciseTypeIds: exerciseTypeIds ?? state.exerciseTypeIds,
        exerciseCategoryIds: exerciseCategoryIds ?? state.exerciseCategoryIds,
        muscleIds: muscleIds ?? state.muscleIds,
        location: location ?? state.location,
      ),
    );
  }

  /// Add exercise to template from entity
  void addExercise(ExerciseListEntity exercise) {
    // Check if exercise already exists
    if (state.exercises.any((e) => e.exerciseId == exercise.id)) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: 'Exercise already added',
        ),
      );
      return;
    }

    final newExercise = WorkoutExerciseFormData(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      exerciseImageUrl: exercise.imageUrl.isNotEmpty ? exercise.imageUrl : null,
      type:
          'reps', // Default to 'reps' type (matches backend enum: reps, time, distance, mixed)
      sets: [const WorkoutSetFormData(setOrder: 1, reps: null, weight: null)],
    );

    final updatedExercises = [...state.exercises, newExercise];
    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Add exercise from raw data (for mock data or quick add)
  void addExerciseFromData({
    required String id,
    required String name,
    String? imageUrl,
  }) {
    // Check if exercise already exists
    if (state.exercises.any((e) => e.exerciseId == id)) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: 'Exercise already added',
        ),
      );
      return;
    }

    final newExercise = WorkoutExerciseFormData(
      exerciseId: id,
      exerciseName: name,
      exerciseImageUrl: imageUrl,
      type: 'reps', // Default to 'reps' type (matches backend enum)
      sets: [const WorkoutSetFormData(setOrder: 1, reps: null, weight: null)],
    );

    final updatedExercises = [...state.exercises, newExercise];
    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Remove exercise from template
  void removeExercise(int exerciseIndex) {
    final updatedExercises = List<WorkoutExerciseFormData>.from(
      state.exercises,
    );
    updatedExercises.removeAt(exerciseIndex);
    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Update exercise type (reps, time, distance, mixed)
  void updateExerciseType(int exerciseIndex, String newType) {
    final updatedExercises = List<WorkoutExerciseFormData>.from(
      state.exercises,
    );
    final exercise = updatedExercises[exerciseIndex];

    // Reset sets with default values based on new type
    final resetSets = exercise.sets.map((set) {
      return WorkoutSetFormData(
        setOrder: set.setOrder,
        reps: (newType == 'reps' || newType == 'time' || newType == 'mixed')
            ? set.reps
            : null,
        weight: (newType == 'reps' || newType == 'mixed') ? set.weight : null,
        duration: (newType == 'time' || newType == 'mixed')
            ? set.duration
            : null,
        distance: (newType == 'distance' || newType == 'mixed')
            ? set.distance
            : null,
        restAfterSetSeconds: (newType != 'distance')
            ? set.restAfterSetSeconds
            : null,
      );
    }).toList();

    updatedExercises[exerciseIndex] = exercise.copyWith(
      type: newType,
      sets: resetSets,
    );

    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Add set to exercise
  void addSet(int exerciseIndex) {
    final updatedExercises = List<WorkoutExerciseFormData>.from(
      state.exercises,
    );
    final exercise = updatedExercises[exerciseIndex];
    final newSetOrder = exercise.sets.length + 1;

    final newSet = WorkoutSetFormData(
      setOrder: newSetOrder,
      reps: null,
      weight: null,
    );

    final updatedSets = [...exercise.sets, newSet];
    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Remove set from exercise
  void removeSet(int exerciseIndex, int setIndex) {
    final updatedExercises = List<WorkoutExerciseFormData>.from(
      state.exercises,
    );
    final exercise = updatedExercises[exerciseIndex];

    final updatedSets = List<WorkoutSetFormData>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    // Re-order remaining sets
    final reorderedSets = updatedSets.asMap().entries.map((entry) {
      return entry.value.copyWith(setOrder: entry.key + 1);
    }).toList();

    updatedExercises[exerciseIndex] = exercise.copyWith(sets: reorderedSets);
    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Update set data
  void updateSet(
    int exerciseIndex,
    int setIndex, {
    int? reps,
    double? weight,
    int? duration,
    double? distance,
    int? restAfterSetSeconds,
    String? notes,
  }) {
    final updatedExercises = List<WorkoutExerciseFormData>.from(
      state.exercises,
    );
    final exercise = updatedExercises[exerciseIndex];
    final updatedSets = List<WorkoutSetFormData>.from(exercise.sets);

    updatedSets[setIndex] = updatedSets[setIndex].copyWith(
      reps: reps,
      weight: weight,
      duration: duration,
      distance: distance,
      restAfterSetSeconds: restAfterSetSeconds,
      notes: notes,
    );

    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    emit(state.copyWith(exercises: updatedExercises));
  }

  /// Validate and prepare for save
  bool validate() {
    if (state.name.trim().isEmpty) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: 'Please enter template name',
        ),
      );
      return false;
    }

    if (state.exercises.isEmpty) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: 'Please add at least one exercise',
        ),
      );
      return false;
    }

    return true;
  }

  /// Prepare data for API
  Map<String, dynamic> prepareDataForApi() {
    return {
      'name': state.name,
      'description': state.description,
      'notes': state.notes,
      'equipments': state.equipmentIds,
      'bodyPartsTarget': state.bodyPartIds,
      'exerciseTypes': state.exerciseTypeIds,
      'exerciseCategories': state.exerciseCategoryIds,
      'musclesTarget': state.muscleIds,
      'location': state.location,
      'workOutDetail': state.exercises.map((exercise) {
        return {
          'exerciseId': exercise.exerciseId,
          'type': exercise.type,
          'sets': exercise.sets.map((set) {
            return {
              'setOrder': set.setOrder,
              'reps': set.reps,
              'weight': set.weight,
              'duration': set.duration,
              'distance': set.distance,
              'restAfterSetSeconds': set.restAfterSetSeconds,
              'notes': set.notes,
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  /// Save template (create or update)
  Future<bool> saveTemplate() async {
    if (!validate()) {
      return false;
    }

    emit(state.copyWith(status: WorkoutTemplateFormStatus.saving));

    try {
      final data = prepareDataForApi();

      if (state.isEditMode && state.templateId.isNotEmpty) {
        // Update existing template
        final response = await updateWorkoutTemplateUseCase(
          state.templateId,
          data,
        );

        if (response.success) {
          emit(state.copyWith(status: WorkoutTemplateFormStatus.saved));
          return true;
        } else {
          emit(
            state.copyWith(
              status: WorkoutTemplateFormStatus.error,
              errorMessage: response.message ?? 'Failed to update template',
            ),
          );
          return false;
        }
      } else {
        // Create new template
        final response = await createWorkoutTemplateUseCase(data);

        if (response.success) {
          emit(state.copyWith(status: WorkoutTemplateFormStatus.saved));
          return true;
        } else {
          emit(
            state.copyWith(
              status: WorkoutTemplateFormStatus.error,
              errorMessage: response.message ?? 'Failed to create template',
            ),
          );
          return false;
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WorkoutTemplateFormStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    emit(
      state.copyWith(
        status: WorkoutTemplateFormStatus.editing,
        errorMessage: null,
      ),
    );
  }
}
