import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/role_guard.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/login_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/register_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/cubits/exercise_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_details/exercise_detail_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/exercise_home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/cubits/info_account_cubit.dart';

import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';

import 'package:omnihealthmobileflutter/presentation/screen/home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/health_profile_page.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_form/personal_profile_form_page.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/goal_form_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/info_account/info_account_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/more_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/change_password/change_password_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/verify_account/verify_account_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/forgot_password/forgot_password_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_form/workout_template_form_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_detail/workout_template_detail_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_detail/cubits/workout_template_detail_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/workout_template_ai_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_template_ai/cubit/workout_template_ai_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/workout_session_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_bloc.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/save_workout_log_usecase.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/workout_log_repository_abs.dart';
import 'package:omnihealthmobileflutter/domain/abstracts/health_connect_repository.dart';
import 'package:omnihealthmobileflutter/domain/usecases/workout/create_workout_feedback_usecase.dart';

class RouteConfig {
  // ==================== ROUTE NAMES ====================
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';

  // Common routes
  static const String main = '/main';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String exerciseHome = '/exercise-home';

  static const String exerciseDetail = '/exercise-detail';
  static const String healthProfile = '/health-profile';
  static const String healthProfileForm = '/health-profile-form';
  static const String goalForm = '/goal-form';

  static const String infoAccount = '/info-account';
  static const String changePassword = '/change-password';
  static const String verifyAccount = '/verify-account';
  static const String workoutTemplateForm = '/workout-template-form';
  static const String workoutTemplateDetail = '/workout-template-detail';
  static const String workoutTemplateAI = '/workout-template-ai';
  static const String workoutSession = '/workout-session';

  // ==================== BUILD AUTH PAGES ====================
  static Widget buildAuthPage(String? routeName) {
    switch (routeName) {
      case register:
        return BlocProvider(
          create: (_) => RegisterCubit(
            registerUseCase: sl(),
            authenticationBloc: sl<AuthenticationBloc>(),
            getRolesForSelectBoxUseCase: sl(),
          ),
          child: const RegisterScreen(),
        );

      case forgetPassword:
        return const ForgotPasswordScreen();

      case login:
      default:
        return BlocProvider(
          create: (_) => LoginCubit(
            loginUseCase: sl(),
            authenticationBloc: sl<AuthenticationBloc>(),
          ),
          child: const LoginScreen(),
        );
    }
  }

  // ==================== BUILD AUTHENTICATED PAGES ====================
  static Widget buildPage({
    required String routeName,
    required List<String>? role,
    Map<String, dynamic>? arguments,
  }) {
    // Kiểm tra quyền truy cập
    if (!RoleGuard.canAccess(role, routeName)) {
      return _ForbiddenPage(role: role, routeName: routeName);
    }

    // Build page theo route
    switch (routeName) {
      // ===== Common Routes =====
      case main:
      case home:
        return _buildMainScreenByRole(role)!;

      case profile:
        return const MoreScreen();

      case settings:
        return const MoreScreen();

      case exerciseHome:
        return BlocProvider(
          create: (_) => sl<ExerciseHomeBloc>()..add(LoadInitialData()),
          child: const ExerciseHomeScreen(),
        );

      case exerciseDetail:
        final exerciseId = arguments?['exerciseId'] as String?;
        if (exerciseId == null) {
          return _ErrorPage(message: 'Exercise ID is required');
        }
        return BlocProvider(
          create: (_) => sl<ExerciseDetailCubit>(),
          child: ExerciseDetailScreen(exerciseId: exerciseId),
        );

      case healthProfile:
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  sl<HealthProfileBloc>()
                    ..add(const GetLatestHealthProfileEvent()),
            ),
            BlocProvider(create: (_) => sl<GoalBloc>()),
          ],
          child: const HealthProfilePage(),
        );

      case healthProfileForm:
        final profileId = arguments?['profileId'] as String?;
        return PersonalProfileFormPage(profileId: profileId);

      case goalForm:
        final goalId = arguments?['goalId'] as String?;
        final goal = arguments?['goal'] as dynamic; // Or GoalEntity if imported
        return BlocProvider(
          create: (_) => sl<GoalBloc>(),
          child: GoalFormScreen(goalId: goalId, existingGoal: goal),
        );

      case infoAccount:
        return BlocProvider(
          create: (_) => sl<InfoAccountCubit>()..loadUserInfo(),
          child: const InfoAccountScreen(),
        );

      case changePassword:
        return const ChangePasswordScreen();

      case verifyAccount:
        return const VerifyAccountScreen();

      case forgetPassword:
        // From authenticated context (e.g., Change Password screen)
        return const ForgotPasswordScreen(fromAuthenticated: true);

      case workoutTemplateForm:
        final templateId = arguments?['templateId'] as String?;
        return WorkoutTemplateFormScreen(templateId: templateId);

      case workoutTemplateDetail:
        final templateId = arguments?['templateId'] as String?;
        if (templateId == null) {
          return _ErrorPage(message: 'Template ID is required');
        }
        return BlocProvider(
          create: (_) => WorkoutTemplateDetailCubit(
            getWorkoutTemplateByIdUseCase: sl(),
            deleteWorkoutTemplateUseCase: sl(),
          ),
          child: WorkoutTemplateDetailScreen(templateId: templateId),
        );

      case workoutTemplateAI:
        return BlocProvider(
          create: (_) => sl<WorkoutTemplateAICubit>()..loadInitialData(),
          child: const WorkoutTemplateAIScreen(),
        );

      case workoutSession:
        final template = arguments?['template'] as WorkoutTemplateEntity?;
        if (template == null) {
          return _ErrorPage(message: 'Workout template is required');
        }
        return BlocProvider(
          create: (_) => WorkoutSessionBloc(
            saveWorkoutLogUseCase: sl<SaveWorkoutLogUseCase>(),
            workoutLogRepository: sl<WorkoutLogRepositoryAbs>(),
            healthConnectRepository: sl<HealthConnectRepository>(),
            createWorkoutFeedbackUseCase: sl<CreateWorkoutFeedbackUseCase>(),
          ),
          child: WorkoutSessionScreen(template: template),
        );

      default:
        return _ErrorPage(message: 'Không tìm thấy trang: $routeName');
    }
  }

  // ==================== BUILD MAIN SCREEN BY ROLE ====================
  static Widget? _buildMainScreenByRole(List<String>? role) {
    // TODO: Return AdminMainScreen by role
    // final normalizedRole = RoleGuard.getNormalizedRole(role);

    // switch (normalizedRole) {
    //   case 'admin':
    // return const MainScreen(); // Placeholder

    //   case 'coach':
    // return const MainScreen(); // Placeholder

    //   case 'user':
    //   default:
    // return const MainScreen();
    // }

    return const HomeScreen();
  }

  // ==================== NAVIGATION HELPERS ====================
  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(register);
  }

  static void navigateToForgetPassword(BuildContext context) {
    Navigator.of(context).pushNamed(forgetPassword);
  }

  static void navigateToMain(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(main, (route) => false);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.of(context).pushNamed(home);
  }

  static void navigateToProfile(
    BuildContext context, {
    Map<String, dynamic>? arguments,
  }) {
    Navigator.of(context).pushNamed(profile, arguments: arguments);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.of(context).pushNamed(settings);
  }

  static void navigateToExerciseHome(BuildContext context) {
    Navigator.of(context).pushNamed(exerciseHome);
  }

  static Future<dynamic> navigateToGoalForm(
    BuildContext context, {
    required String userId,
    String? goalId,
    dynamic goal,
  }) {
    return Navigator.of(context).pushNamed(
      goalForm,
      arguments: {'userId': userId, 'goalId': goalId, 'goal': goal},
    );
  }

  static void navigateToInfoAccount(BuildContext context) {
    Navigator.of(context).pushNamed(infoAccount);
  }

  static void navigateToChangePassword(BuildContext context) {
    Navigator.of(context).pushNamed(changePassword);
  }

  static void navigateToVerifyAccount(BuildContext context) {
    Navigator.of(context).pushNamed(verifyAccount);
  }

  static Future<dynamic> navigateToWorkoutTemplateDetail(
    BuildContext context, {
    required String templateId,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(workoutTemplateDetail, arguments: {'templateId': templateId});
  }

  static Future<dynamic> navigateToWorkoutTemplateForm(
    BuildContext context, {
    String? templateId,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(workoutTemplateForm, arguments: {'templateId': templateId});
  }

  static void navigateToWorkoutTemplateAI(BuildContext context) {
    Navigator.of(context).pushNamed(workoutTemplateAI);
  }

  static Future<dynamic> navigateToWorkoutSession(
    BuildContext context, {
    required WorkoutTemplateEntity template,
  }) {
    return Navigator.of(
      context,
    ).pushNamed(workoutSession, arguments: {'template': template});
  }
}

// ==================== ERROR PAGES ====================

/// Trang hiển thị khi không đủ quyền
class _ForbiddenPage extends StatelessWidget {
  final List<String>? role;
  final String routeName;

  const _ForbiddenPage({required this.role, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không có quyền truy cập'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 80.w, color: Colors.red),
              SizedBox(height: 24.h),
              Text(
                'Không có quyền truy cập',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Bạn không có quyền truy cập trang này.\nVai trò của bạn: ${role ?? "Không xác định"}',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trang hiển thị khi có lỗi
class _ErrorPage extends StatelessWidget {
  final String message;

  const _ErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lỗi'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80.w, color: Colors.orange),
              SizedBox(height: 24.h),
              Text(
                'Có lỗi xảy ra',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
