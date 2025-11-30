---
description: Workflow for syncing and aggregating workout data from devices
---

# Workout Data Aggregation Pipeline

This workflow describes how to handle workout data (heart rate, calories) from devices (Apple Watch, Health Connect) and aggregate it into the Workout history.

## Overview

Instead of calculating data on the client, we use a **Server-side Aggregation** strategy.

1. **Continuous Sync**: The client syncs `WatchLog` data to the server periodically.
2. **Trigger**: When an exercise finishes, the client triggers a "Force Sync" for that specific time range.
3. **Aggregation**: The server aggregates the `WatchLog` entries to calculate total calories, avg heart rate, etc.

## Client-Side Implementation (Flutter)

When a user finishes an exercise (Set or Workout Detail):

1.  **Capture Time**: Record the `startTime` and `endTime` of the exercise.
2.  **Force Sync**: Call `syncHealthDataForRange` to ensure the server has the latest data.
3.  **Complete Exercise**: Call the API `completeExercise` with the time range.

```dart
// Example Usage in Bloc/Provider

Future<void> onFinishExercise(String workoutId, String exerciseId, DateTime start, DateTime end) async {
  // 1. Force Sync Health Data
  await healthConnectRepository.syncHealthDataForRange(start, end);

  // 2. Call API to complete exercise
  // Note: Ensure your API client sends startTime and endTime in ISO format
  await workoutRepository.completeExercise(
    workoutId: workoutId,
    workoutDetailId: exerciseId,
    startTime: start,
    endTime: end,
  );
}
```

## Server-Side Logic

The `WorkoutService.completeExercise` method now performs the following:

1.  **Calculate Duration**: Based on `startTime` and `endTime`.
2.  **Query WatchLogs**: Finds all `WatchLog` entries for the user within the time range.
3.  **Aggregate**:
    - `caloriesBurned`: Sum of all logs.
    - `heartRateAvg`: Average of all logs.
    - `heartRateMax`: Max of all logs.
4.  **Fallback**: If no logs are found (user didn't wear device or sync failed), it falls back to the MET calculation formula.
5.  **Update DB**: Updates `Workout.workoutDetail.deviceData`.

## Files Modified

- **Server**:

  - `src/domain/repositories/Devices/WatchLog.repository.ts`: Added `findLogsByTimeRange`.
  - `src/domain/services/Workout/Workout.service.ts`: Implemented aggregation logic.
  - `src/domain/controllers/Workout/Workout.controller.ts`: Updated to receive time range.
  - `src/domain/routes/workout.route.ts`: Dependency injection.

- **Client**:
  - `lib/domain/abstracts/health_connect_repository.dart`: Added `syncHealthDataForRange`.
  - `lib/data/repositories/health_connect_repository_impl.dart`: Implemented `syncHealthDataForRange`.
