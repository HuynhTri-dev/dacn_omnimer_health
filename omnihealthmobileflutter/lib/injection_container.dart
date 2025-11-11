import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:omnihealthmobileflutter/core/api/api_client.dart';
import 'package:omnihealthmobileflutter/data/datasources/auth_datasource.dart';
import 'package:omnihealthmobileflutter/data/repositories/auth_repository_impl.dart';
import 'package:omnihealthmobileflutter/services/firebase_auth_service.dart';
import 'package:omnihealthmobileflutter/services/firebase_storage_uploader.dart';
import 'package:omnihealthmobileflutter/services/secure_storage_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ======================
  // Core
  // ======================
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // ======================
  // Services
  // ======================
  sl.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthServiceImpl(firebaseAuth: FirebaseAuth.instance),
  );
  sl.registerLazySingleton<FirebaseStorageUploader>(
    () => FirebaseStorageUploader(),
  );
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // ======================
  // DataSources
  // ======================
  sl.registerLazySingleton<AuthDataSourceImpl>(
    () => AuthDataSourceImpl(
      apiClient: sl(),
      secureStorage: sl(),
      firebaseAuthService: sl(),
      sharedPreferencesService: sl(),
    ),
  );

  // ======================
  // Repositories
  // ======================
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(authDataSource: sl()),
  );

  // ======================
  // Blocs / Cubits
  // ======================
  // sl.registerLazySingleton(
  //   () => AuthenticationBloc(
  //     getCurrentUserUseCase: sl(),
  //     logoutUserUseCase: sl(),
  //   ),
  // );

  // sl.registerFactory(
  //   () => RegistrationBloc(
  //     registerUserUseCase: sl(),
  //     uploader: sl(),
  //     getAllRolesUseCase: sl(),
  //     uploadTempAvatarUseCase: sl(),
  //   ),
  // );

  // sl.registerFactory(
  //   () => LoginBloc(loginUseCase: sl(), authenticationBloc: sl()),
  // );
}
