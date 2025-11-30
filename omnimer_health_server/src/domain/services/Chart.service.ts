import {
  GoalRepository,
  HealthProfileRepository,
  WorkoutRepository,
  WorkoutTemplateRepository,
} from "../repositories";

export class ChartService {
  private readonly healthProfileRepo: HealthProfileRepository;
  private readonly workoutRepo: WorkoutRepository;
  private readonly workoutTemplateRepo: WorkoutTemplateRepository;
  private readonly goalRepo: GoalRepository;

  constructor(
    healthProfileRepo: HealthProfileRepository,
    workoutRepo: WorkoutRepository,
    workoutTemplateRepo: WorkoutTemplateRepository,
    goalRepo: GoalRepository
  ) {
    this.healthProfileRepo = healthProfileRepo;
    this.workoutRepo = workoutRepo;
    this.workoutTemplateRepo = workoutTemplateRepo;
    this.goalRepo = goalRepo;
  }

  // 1. Weight Progress Chart
  async getWeightProgress(userId: string) {
    const profiles = await this.healthProfileRepo.getWeightHistory(userId);
    return profiles.map((p) => ({
      date: p.checkupDate,
      weight: p.weight,
    }));
  }

  // 2. Workout Frequency Chart (Workouts per week)
  async getWorkoutFrequency(userId: string) {
    const workouts = await this.workoutRepo.getWorkoutsForFrequency(userId);

    const frequencyMap: Record<string, number> = {};

    workouts.forEach((w) => {
      const date = new Date(w.timeStart);
      const year = date.getFullYear();
      const week = this.getWeekNumber(date);
      const key = `${year}-W${week}`;

      frequencyMap[key] = (frequencyMap[key] || 0) + 1;
    });

    return Object.entries(frequencyMap)
      .map(([period, count]) => ({ period, count }))
      .sort((a, b) => a.period.localeCompare(b.period));
  }

  // Helper to get week number
  private getWeekNumber(d: Date): number {
    d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
    d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7));
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    const weekNo = Math.ceil(
      ((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7
    );
    return weekNo;
  }

  // 3. Calories Burned Chart
  async getCaloriesBurned(userId: string) {
    const history = await this.workoutRepo.getCaloriesBurnedHistory(userId);
    return history.map((h) => ({
      date: h.timeStart,
      calories: h.calories,
    }));
  }

  // 4. Muscle Distribution Chart
  async getMuscleDistribution(userId: string) {
    return await this.workoutRepo.getMuscleDistributionStats(userId);
  }

  // 5. Goal Progress Chart (Active vs Completed vs Expired)
  async getGoalProgress(userId: string) {
    const goals = await this.goalRepo.getAllGoals(userId);

    const now = new Date();
    const stats = {
      active: 0,
      completed: 0,
      expired: 0,
    };

    goals.forEach((g) => {
      if (g.endDate < now) {
        stats.expired++;
      } else {
        stats.active++;
      }
    });

    return [
      { status: "Active", count: stats.active },
      { status: "Expired", count: stats.expired },
    ];
  }
}
