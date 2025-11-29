# Health Connect Integration Workflow

This document outlines the workflow for connecting the application to Health Connect and synchronizing health data with the backend.

## Overview

The integration aims to sync user health data (steps, heart rate, sleep, etc.) from Health Connect to the Omnimer Health Server. It involves two main modes:

1.  **Background Synchronization**: Automatically syncing daily stats.
2.  **Workout Session Synchronization**: Syncing specific workout sessions when the user engages in exercise.

## Workflow Steps

### 1. Connection Initialization

- **User Action**: User toggles "Connect Health Data" (or similar) to ON in the app settings.
- **System Action**:
  - Request necessary permissions from Health Connect (READ access for Steps, Heart Rate, Sleep, Workout, etc.).
  - Upon approval, save the connection status (e.g., `isHealthConnectLinked = true`) locally and potentially on the user profile.

### 2. Data Synchronization (Background/Periodic)

- **Trigger**: Health Connect has new data available, or the app polls periodically/on foreground.
- **Process**:
  1.  Fetch latest data from Health Connect since the last sync timestamp.
  2.  Data types to sync:
      - **Steps** -> `steps`
      - **Heart Rate** -> `heartRateAvg`, `heartRateRest`, `heartRateMax`
      - **Sleep** -> `sleepDuration`, `sleepQuality`
      - **Activity** -> `activeMinutes`, `caloriesBurned`, `distance`
      - **Vitals** -> `vo2max`, `stressLevel`
  3.  Format data into `WatchLog` objects.
- **Backend Action**:
  - **API Endpoint**: `POST /api/v1/watch-logs` (or `POST /api/v1/watch-logs/many` for batch updates).
  - **Payload**:
    ```json
    {
      "userId": "USER_ID",
      "nameDevice": "HealthConnect", // or specific device name if available
      "date": "2023-10-27T10:00:00Z",
      "steps": 1500,
      "heartRateAvg": 75,
      "caloriesBurned": 300
      // ... other fields
    }
    ```

### 3. Workout Session Mode

- **User Action**: User starts a workout session in the app (or the app detects a workout from Health Connect).
- **Process**:
  1.  Enable "Workout Mode" to track specific session data.
  2.  Upon completion of the workout:
      - Retrieve the specific workout session data (duration, avg heart rate, calories, distance).
      - Associate with a `workoutId` or `exerciseId` if the workout was initiated from an app plan.
- **Backend Action**:
  - **API Endpoint**: `POST /api/v1/watch-logs`
  - **Payload**:
    ```json
    {
      "userId": "USER_ID",
      "workoutId": "WORKOUT_ID", // Optional
      "nameDevice": "HealthConnect",
      "date": "2023-10-27T15:30:00Z",
      "activeMinutes": 45,
      "caloriesBurned": 450,
      "heartRateAvg": 140,
      "heartRateMax": 170
    }
    ```

## Backend Resources

### API Routes

- **File**: `omnimer_health_server/src/domain/routes/watch-log.route.ts`
- **Endpoints**:
  - `POST /`: Create a single log entry.
  - `POST /many`: Create multiple log entries (useful for background sync).

### Data Model

- **File**: `omnimer_health_server/src/domain/models/Devices/WatchLog.model.ts`
- **Key Fields**:
  - `userId`: Required.
  - `nameDevice`: Enum (Ensure 'HealthConnect' or similar is supported or mapped to an existing enum value).
  - `date`: Timestamp of the log.
  - `steps`, `distance`, `caloriesBurned`: Activity metrics.
  - `heartRate...`: Cardiovascular metrics.
  - `sleep...`: Recovery metrics.

## Implementation Notes

- Ensure `verifyAccessToken` middleware is handled by sending the correct Bearer token in requests.
- Handle duplicate data: The backend or frontend should check if data for a specific time range already exists to avoid double-counting (though `WatchLog` seems to be log-based, maybe aggregated by date/time).
- **Permissions**: Ensure the AndroidManifest (for Android) is correctly configured for Health Connect permissions.
