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
import 'package:omnihealthmobileflutter/presentation/screen/home_screen.dart';

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
      // TODO: Implement ForgetPasswordCubit
      // return const ForgetPasswordScreen();

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
        return _buildProfileScreen(role, arguments);

      case settings:
        return _buildSettingsScreen(role, arguments);

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

  // ==================== COMMON SCREENS ====================
  // static Widget _buildMuscleHomeScreen(
  //   List<String>? role,
  //   Map<String, dynamic>? arguments,
  // ) {
  //   Navigator.of(context).pushNamedAndRemoveUntil(login, (route) => false);
  // }

  static Widget _buildProfileScreen(
    List<String>? role,
    Map<String, dynamic>? arguments,
  ) {
    // TODO: Implement profile screen với custom layout theo role
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }

  static Widget _buildSettingsScreen(
    List<String>? role,
    Map<String, dynamic>? arguments,
  ) {
    // TODO: Implement settings screen
    return const Scaffold(body: Center(child: Text('Settings Screen')));
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
