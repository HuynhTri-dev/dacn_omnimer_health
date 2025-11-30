import {
  ExerciseRepository,
  UserRepository,
  WorkoutRepository,
} from "../repositories";

export class AdminChartService {
  private readonly userRepo: UserRepository;
  private readonly workoutRepo: WorkoutRepository;
  private readonly exerciseRepo: ExerciseRepository;

  constructor(
    userRepo: UserRepository,
    workoutRepo: WorkoutRepository,
    exerciseRepo: ExerciseRepository
  ) {
    this.userRepo = userRepo;
    this.workoutRepo = workoutRepo;
    this.exerciseRepo = exerciseRepo;
  }

  // 1. User Growth Chart
  async getUserGrowth(period: "daily" | "weekly" | "monthly") {
    return await this.userRepo.getUserGrowthStats(period);
  }

  // 2. Workout Activity Chart
  async getWorkoutActivity(period: "daily" | "weekly" | "monthly") {
    return await this.workoutRepo.getWorkoutActivityStats(period);
  }

  // 3. Popular Exercises Chart
  async getPopularExercises(limit: number = 5) {
    return await this.workoutRepo.getPopularExercisesStats(limit);
  }

  // 4. System Summary
  async getSystemSummary() {
    const [totalUsers, totalWorkouts, totalExercises] = await Promise.all([
      this.userRepo.countUsers(),
      this.workoutRepo.countWorkouts(),
      this.exerciseRepo.countExercises(),
    ]);

    return {
      totalUsers,
      totalWorkouts,
      totalExercises,
    };
  }
}
