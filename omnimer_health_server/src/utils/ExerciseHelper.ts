import { DifficultyLevelEnum } from "../common/constants/EnumConstants";
import { IRAGHealthProfile } from "../domain/entities";

/**
 * Returns a range of suitable exercise difficulty levels
 * based on user's health and experience profile.
 * Allows flexible matching (e.g., Beginner can also train some Intermediate exercises).
 *
 * @param {IRAGHealthProfile} profile - The user's RAG health profile.
 * @returns {DifficultyLevelEnum[]} List of suitable difficulty levels.
 *
 * @example
 * const levels = getSuitableDifficultyLevels(profile);
 * // => [DifficultyLevelEnum.Beginner, DifficultyLevelEnum.Intermediate]
 */
export function getSuitableDifficultyLevels(
  profile: IRAGHealthProfile
): DifficultyLevelEnum[] {
  // Base on explicit experience level first
  let baseLevel: DifficultyLevelEnum | null = null;

  if (profile.experienceLevel) {
    const level = profile.experienceLevel.toLowerCase();
    if (level.includes("beginner")) baseLevel = DifficultyLevelEnum.Beginner;
    else if (level.includes("intermediate"))
      baseLevel = DifficultyLevelEnum.Intermediate;
    else if (level.includes("advanced"))
      baseLevel = DifficultyLevelEnum.Advanced;
    else if (level.includes("expert")) baseLevel = DifficultyLevelEnum.Expert;
  }

  // If not defined, infer by activity and training data
  if (!baseLevel) {
    const activity = profile.activityLevel ?? 0;
    const frequency = profile.workoutFrequency ?? 0;
    const strength = profile.maxWeightLifted ?? 0;

    if (activity <= 2 || frequency <= 2)
      baseLevel = DifficultyLevelEnum.Beginner;
    else if (activity <= 3 || frequency <= 4)
      baseLevel = DifficultyLevelEnum.Intermediate;
    else if (activity >= 4 && strength > 70)
      baseLevel = DifficultyLevelEnum.Advanced;
    else if (activity >= 5 && strength > 100)
      baseLevel = DifficultyLevelEnum.Expert;
    else baseLevel = DifficultyLevelEnum.Beginner;
  }

  // Define “adjacent difficulty mapping”
  const flexibilityMap: Record<DifficultyLevelEnum, DifficultyLevelEnum[]> = {
    [DifficultyLevelEnum.Beginner]: [
      DifficultyLevelEnum.Beginner,
      DifficultyLevelEnum.Intermediate,
    ],
    [DifficultyLevelEnum.Intermediate]: [
      DifficultyLevelEnum.Beginner,
      DifficultyLevelEnum.Intermediate,
      DifficultyLevelEnum.Advanced,
    ],
    [DifficultyLevelEnum.Advanced]: [
      DifficultyLevelEnum.Intermediate,
      DifficultyLevelEnum.Advanced,
      DifficultyLevelEnum.Expert,
    ],
    [DifficultyLevelEnum.Expert]: [
      DifficultyLevelEnum.Advanced,
      DifficultyLevelEnum.Expert,
    ],
  };

  return flexibilityMap[baseLevel];
}
