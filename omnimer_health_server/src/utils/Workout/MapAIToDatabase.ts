import { Types } from "mongoose";
import { WorkoutDetailTypeEnum } from "../../common/constants/EnumConstants";
import { IWorkoutTemplateDetail } from "../../domain/models";
import { IRAGAIResponse } from "../../domain/entities";

export function mapAIResponseToWorkoutDetail(
  aiResponse: IRAGAIResponse
): IWorkoutTemplateDetail[] {
  return aiResponse.exercises.map<IWorkoutTemplateDetail>((ex) => {
    // Determine type based on first set (can be improved by checking all sets)
    const firstSet = ex.sets[0];
    let type: WorkoutDetailTypeEnum = WorkoutDetailTypeEnum.Mixed;

    if (firstSet) {
      const hasReps = firstSet.reps !== undefined;
      const hasTime = firstSet.min !== undefined;
      const hasDistance = firstSet.km !== undefined;

      if (hasReps && !hasTime && !hasDistance)
        type = WorkoutDetailTypeEnum.Reps;
      else if (!hasReps && hasTime && !hasDistance)
        type = WorkoutDetailTypeEnum.Time;
      else if (!hasReps && !hasTime && hasDistance)
        type = WorkoutDetailTypeEnum.Distance;
      else type = WorkoutDetailTypeEnum.Mixed;
    }

    return {
      exerciseId: new Types.ObjectId(), // TODO: map ex.name -> Exercise._id
      type,
      sets: ex.sets.map((s, idx) => ({
        setOrder: idx + 1,
        reps: s.reps,
        weight: s.kg,
        duration: s.min ? s.min * 60 : undefined, // convert minutes to seconds
        distance: s.km,
        restAfterSetSeconds: s.minRest ? s.minRest * 60 : 0,
      })),
    };
  });
}
