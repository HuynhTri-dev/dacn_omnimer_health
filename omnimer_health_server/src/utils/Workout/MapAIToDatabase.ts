import { Types } from "mongoose";
import { WorkoutDetailTypeEnum } from "../../common/constants/EnumConstants";
import { IWorkoutTemplateDetail } from "../../domain/models";
import { IRAGAIResponse, IRAGExercise } from "../../domain/entities";

export function mapAIResponseToWorkoutDetail(
  aiResponse: IRAGAIResponse,
  exerciseStuitable: IRAGExercise[]
): IWorkoutTemplateDetail[] {
  return aiResponse.exercises.map<IWorkoutTemplateDetail>((ex) => {
    // Determine type based on first set (can be improved by checking all sets)
    const firstSet = ex.sets[0];
    let type: WorkoutDetailTypeEnum = WorkoutDetailTypeEnum.Mixed;

    if (firstSet) {
      const hasReps = firstSet.reps !== undefined;
      const hasTime = firstSet.duration !== undefined;
      const hasDistance = firstSet.distance !== undefined;

      if (hasReps && !hasTime && !hasDistance)
        type = WorkoutDetailTypeEnum.Reps;
      else if (!hasReps && hasTime && !hasDistance)
        type = WorkoutDetailTypeEnum.Time;
      else if (!hasReps && !hasTime && hasDistance)
        type = WorkoutDetailTypeEnum.Distance;
      else type = WorkoutDetailTypeEnum.Mixed;
    }

    const matchedExercise = exerciseStuitable.find(
      (e) => e.exerciseName === ex.name
    );

    return {
      exerciseId: matchedExercise
        ? new Types.ObjectId(matchedExercise.exerciseId)
        : new Types.ObjectId(),
      type,
      sets: ex.sets.map((s, idx) => ({
        setOrder: idx + 1,
        reps: s.reps ?? undefined,
        weight: s.kg ?? undefined,
        duration: s.duration ?? undefined,
        distance: s.distance ?? undefined,
        restAfterSetSeconds: s.restAfterSetSeconds ?? undefined,
      })),
    };
  });
}
