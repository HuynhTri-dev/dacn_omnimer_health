import 'package:get_it/get_it.dart';
import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/body_part_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/equipment_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_category_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_rating_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/exercise_type_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/musce_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/role_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/watch_log_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/health_profile_remote_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/goal_remote_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/workout_datasource.dart';

import 'package:omnihealthmobileflutter/data/repositories/auth_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/body_part_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/equipment_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_category_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_rating_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_type_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/muscle_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/role_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/health_profile_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/goal_repository_impl.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/body_part_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/equipment_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_category_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_rating_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_type_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/role_repositoy_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_profile_repository.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/goal_repository.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_auth_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/login_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/logout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/register_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/update_user_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercise_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_muscle_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/rate_exercise_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/get_goal_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/role/get_roles_for_select_box_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_latest_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profiles_by_user_id.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/create_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/update_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/delete_health_profile.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_profile/get_health_profile_by_date.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/create_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/delete_goal_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/get_goals_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/goal/update_goal_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';
import 'package:omnihealthmobileflutter/services/shared_preferences_service.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_form/bloc/health_profile_form_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/cubits/info_account_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_connect/bloc/health_connect_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_bloc.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/data/repositories/health_connect_repository_impl.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_template_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_stats_repository_abs.dart';
import 'package:omnihealthmobileflutter/data/repositories/workout_template_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/workout_stats_repository_impl.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/check_health_connect_availability.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/request_health_permissions.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/get_today_health_data.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/get_health_data_range.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/sync_health_data_to_backend.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/start_workout_session.dart';
import 'package:omnihealthmobileflutter/domain/usecases/health_connect/stop_workout_session.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_templates_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_user_workout_templates_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_workout_template_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/delete_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/get_weekly_workout_stats_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/create_workout_template_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/update_workout_template_usecase.dart';
import 'package:health/health.dart';
import 'package:logger/logger.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/healthkit_connect_abs.dart';
import 'package:omnihealthmobileflutter/data/repositories/healthkit_connect_impl.dart';
import 'package:omnihealthmobileflutter/presentation/screen/healthkit_connect/bloc/healthkit_connect_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ======================
  // Core
  // ======================
  sl.registerLazySingleton<ApiClient>(() => ApiClient(secureStorage: sl()));
  sl.registerLazySingleton<Logger>(() => Logger());
  sl.registerLazySingleton<Health>(() => Health());

  // ======================
  // Services
  // ======================
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<SharedPreferencesService>(
    () => SharedPreferencesService(),
  );

  // ======================
  // DataSources
  // ======================
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(
      apiClient: sl(),
      secureStorage: sl(),
      sharedPreferencesService: sl(),
    ),
  );
  sl.registerLazySingleton<RoleDataSource>(
    () => RoleDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<BodyPartDataSource>(
    () => BodyPartDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<EquipmentDataSource>(
    () => EquipmentDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ExerciseTypeDataSource>(
    () => ExerciseTypeDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ExerciseCategoryDataSource>(
    () => ExerciseCategoryDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<MuscleDataSource>(
    () => MuscleDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ExerciseDataSource>(
    () => ExerciseDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<ExerciseRatingDataSource>(
    () => ExerciseRatingDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<WatchLogDataSource>(
    () => WatchLogDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<HealthProfileRemoteDataSource>(
    () => HealthProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<GoalRemoteDataSource>(
    () => GoalRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<WorkoutDataSource>(
    () => WorkoutDataSource(apiClient: sl()),
  );

  // ======================
  // Repositories
  // ======================
  sl.registerLazySingleton<AuthRepositoryAbs>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );
  sl.registerLazySingleton<RoleRepositoryAbs>(
    () => RoleRepositoryImpl(roleDataSource: sl()),
  );
  sl.registerLazySingleton<BodyPartRepositoryAbs>(
    () => BodyPartRepositoryImpl(bodyPartDataSource: sl()),
  );
  sl.registerLazySingleton<EquipmentRepositoryAbs>(
    () => EquipmentRepositoryImpl(equipmentDataSource: sl()),
  );
  sl.registerLazySingleton<ExerciseTypeRepositoryAbs>(
    () => ExerciseTypeRepositoryImpl(exerciseTypeDataSource: sl()),
  );
  sl.registerLazySingleton<ExerciseCategoryRepositoryAbs>(
    () => ExerciseCategoryRepositoryImpl(exerciseCategoryDataSource: sl()),
  );

  sl.registerLazySingleton<ExerciseRepositoryAbs>(
    () => ExerciseRepositoryImpl(exerciseDataSource: sl()),
  );

  sl.registerLazySingleton<MuscleRepositoryAbs>(
    () => MuscleRepositoryImpl(muscleDataSource: sl()),
  );

  sl.registerLazySingleton<ExerciseRatingRepositoryAbs>(
    () => ExerciseRatingRepositoryImpl(exerciseRatingDataSource: sl()),
  );

  sl.registerLazySingleton<HealthProfileRepository>(
    () => HealthProfileRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GoalRepository>(
    () => GoalRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<HealthConnectRepository>(
    () => HealthConnectRepositoryImpl(sl(), sl(), sl(), sl()),
  );

  // Workout Repositories
  sl.registerLazySingleton<WorkoutTemplateRepositoryAbs>(
    () => WorkoutTemplateRepositoryImpl(workoutDataSource: sl()),
  );
  sl.registerLazySingleton<WorkoutStatsRepositoryAbs>(
    () => WorkoutStatsRepositoryImpl(workoutDataSource: sl()),
  );

  // ======================
  // Use case
  // ======================
  sl.registerLazySingleton<GetAuthUseCase>(() => GetAuthUseCase(sl()));
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(sl()));
  sl.registerLazySingleton<RefreshTokenUseCase>(
    () => RefreshTokenUseCase(sl()),
  );
  sl.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(sl()));
  sl.registerLazySingleton<UpdateUserUseCase>(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton<GetRolesForSelectBoxUseCase>(
    () => GetRolesForSelectBoxUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllBodyPartsUseCase>(
    () => GetAllBodyPartsUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllEquipmentsUseCase>(
    () => GetAllEquipmentsUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllExerciseTypesUseCase>(
    () => GetAllExerciseTypesUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllExerciseCategoriesUseCase>(
    () => GetAllExerciseCategoriesUseCase(sl()),
  );
  sl.registerLazySingleton<GetExercisesUseCase>(
    () => GetExercisesUseCase(sl()),
  );
  sl.registerLazySingleton<GetMuscleByIdUsecase>(
    () => GetMuscleByIdUsecase(sl()),
  );
  sl.registerLazySingleton<RateExerciseUseCase>(
    () => RateExerciseUseCase(sl()),
  );
  sl.registerLazySingleton<GetExerciseByIdUseCase>(
    () => GetExerciseByIdUseCase(sl()),
  );
  sl.registerLazySingleton<GetAllMuscleTypesUseCase>(
    () => GetAllMuscleTypesUseCase(sl()),
  );

  sl.registerLazySingleton<GetHealthProfilesUseCase>(
    () => GetHealthProfilesUseCase(sl()),
  );
  sl.registerLazySingleton<GetHealthProfileByIdUseCase>(
    () => GetHealthProfileByIdUseCase(sl()),
  );
  sl.registerLazySingleton<GetLatestHealthProfileUseCase>(
    () => GetLatestHealthProfileUseCase(sl()),
  );
  sl.registerLazySingleton<GetHealthProfileByDateUseCase>(
    () => GetHealthProfileByDateUseCase(sl()),
  );
  sl.registerLazySingleton<GetHealthProfilesByUserIdUseCase>(
    () => GetHealthProfilesByUserIdUseCase(sl()),
  );
  sl.registerLazySingleton<CreateHealthProfileUseCase>(
    () => CreateHealthProfileUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateHealthProfileUseCase>(
    () => UpdateHealthProfileUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteHealthProfileUseCase>(
    () => DeleteHealthProfileUseCase(sl()),
  );

  sl.registerLazySingleton<GetGoalsUseCase>(() => GetGoalsUseCase(sl()));
  sl.registerLazySingleton<CreateGoalUseCase>(() => CreateGoalUseCase(sl()));
  sl.registerLazySingleton<UpdateGoalUseCase>(() => UpdateGoalUseCase(sl()));
  sl.registerLazySingleton<DeleteGoalUseCase>(() => DeleteGoalUseCase(sl()));
  sl.registerLazySingleton<GetGoalByIdUseCase>(() => GetGoalByIdUseCase(sl()));

  // Health Connect Use Cases
  sl.registerLazySingleton<CheckHealthConnectAvailabilityUseCase>(
    () => CheckHealthConnectAvailabilityUseCase(sl()),
  );
  sl.registerLazySingleton<RequestHealthPermissionsUseCase>(
    () => RequestHealthPermissionsUseCase(sl()),
  );
  sl.registerLazySingleton<GetTodayHealthDataUseCase>(
    () => GetTodayHealthDataUseCase(sl()),
  );
  sl.registerLazySingleton<GetHealthDataRangeUseCase>(
    () => GetHealthDataRangeUseCase(sl()),
  );
  sl.registerLazySingleton<SyncHealthDataToBackendUseCase>(
    () => SyncHealthDataToBackendUseCase(sl()),
  );
  sl.registerLazySingleton<StartWorkoutSessionUseCase>(
    () => StartWorkoutSessionUseCase(sl()),
  );
  sl.registerLazySingleton<StopWorkoutSessionUseCase>(
    () => StopWorkoutSessionUseCase(sl()),
  );

  // Workout Template Use Cases
  sl.registerLazySingleton<GetWorkoutTemplatesUseCase>(
    () => GetWorkoutTemplatesUseCase(sl()),
  );
  sl.registerLazySingleton<GetUserWorkoutTemplatesUseCase>(
    () => GetUserWorkoutTemplatesUseCase(sl()),
  );
  sl.registerLazySingleton<GetWorkoutTemplateByIdUseCase>(
    () => GetWorkoutTemplateByIdUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteWorkoutTemplateUseCase>(
    () => DeleteWorkoutTemplateUseCase(sl()),
  );
  sl.registerLazySingleton<GetWeeklyWorkoutStatsUseCase>(
    () => GetWeeklyWorkoutStatsUseCase(sl()),
  );
  sl.registerLazySingleton<CreateWorkoutTemplateUseCase>(
    () => CreateWorkoutTemplateUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateWorkoutTemplateUseCase>(
    () => UpdateWorkoutTemplateUseCase(sl()),
  );

  // ======================
  // Blocs / Cubits
  // ======================
  sl.registerLazySingleton(() => ThemeCubit());

  sl.registerLazySingleton(
    () => AuthenticationBloc(getAuthUseCase: sl(), logoutUseCase: sl()),
  );

  sl.registerFactory(
    () => RegisterCubit(
      registerUseCase: sl(),
      authenticationBloc: sl(),
      getRolesForSelectBoxUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => LoginCubit(loginUseCase: sl(), authenticationBloc: sl()),
  );

  sl.registerFactory(
    () => ExerciseHomeBloc(
      getAllBodyPartsUseCase: sl(),
      getAllEquipmentsUseCase: sl(),
      getAllExerciseTypesUseCase: sl(),
      getAllExerciseCategoriesUseCase: sl(),
      getAllMusclesUseCase: sl(),
      getExercisesUseCase: sl(),
      getMuscleByIdUsecase: sl(),
    ),
  );

  sl.registerFactory(
    () => ExerciseDetailCubit(
      getExerciseByIdUseCase: sl(),
      rateExerciseUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => HealthProfileBloc(
      getHealthProfilesUseCase: sl(),
      getHealthProfileByIdUseCase: sl(),
      getLatestHealthProfileUseCase: sl(),
      getHealthProfileByDateUseCase: sl(),
      getHealthProfilesByUserIdUseCase: sl(),
      createHealthProfileUseCase: sl(),
      updateHealthProfileUseCase: sl(),
      deleteHealthProfileUseCase: sl(),
      getGoalsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => HealthProfileFormBloc(
      getHealthProfileByIdUseCase: sl(),
      createHealthProfileUseCase: sl(),
      updateHealthProfileUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => GoalBloc(
      createGoalUseCase: sl(),
      updateGoalUseCase: sl(),
      deleteGoalUseCase: sl(),
      getGoalByIdUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => InfoAccountCubit(
      sharedPreferencesService: sl(),
      updateUserUseCase: sl(),
      authenticationBloc: sl(),
    ),
  );

  // Health Connect BLoC
  sl.registerFactory(
    () => HealthConnectBloc(
      repository: sl(),
      checkAvailability: sl(),
      requestPermissions: sl(),
      getTodayHealthData: sl(),
      getHealthDataRange: sl(),
      syncDataToBackend: sl(),
      startWorkoutSession: sl(),
      stopWorkoutSession: sl(),
    ),
  );

  // Workout Home BLoC
  sl.registerFactory(
    () => WorkoutHomeBloc(
      getWeeklyWorkoutStatsUseCase: sl(),
      getWorkoutTemplatesUseCase: sl(),
      getUserWorkoutTemplatesUseCase: sl(),
      deleteWorkoutTemplateUseCase: sl(),
    ),
  );
}
