import 'package:get_it/get_it.dart';
import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/datasources/role_datasource.dart';
import 'package:omnihealthmobileflutter/data/repositories/auth_repository_impl.dart';
import 'package:omnihealthmobileflutter/data/repositories/role_repository_impl.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/auth_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/role_repositoy_abs.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/get_auth_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/login_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/logout_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/auth/register_usecase.dart';
import 'package:omnihealthmobileflutter/domain/usecases/role/get_roles_for_select_box_usecase.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
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
  // sl.registerLazySingleton<MuscleDataSource>(
  //   () => MuscleDataSourceImpl(apiClient: sl()),
  // );

  // ======================
  // Repositories
  // ======================
  sl.registerLazySingleton<AuthRepositoryAbs>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );
  sl.registerLazySingleton<RoleRepositoryAbs>(
    () => RoleRepositoryImpl(roleDataSource: sl()),
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
}
