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
import 'package:omnihealthmobileflutter/data/repositories/auth_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/body_part_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/equipment_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_category_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_rating_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/exercise_type_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/muscle_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/role_repository_impl.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/body_part_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/equipment_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_category_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_rating_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/exercise_type_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/muscle_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/role_repositoy_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_auth_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/login_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/logout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/register_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_body_parts_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_equipments_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_categories_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_exercise_types_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_all_muscles_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercise_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_exercises_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/get_muscle_by_id_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/exercise/rate_exercise_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/role/get_roles_for_select_box_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';
import 'package:omnihealthmobileflutter/services/shared_preferences_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ======================
  // Core
  // ======================
  sl.registerLazySingleton<ApiClient>(() => ApiClient(secureStorage: sl()));

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
}
