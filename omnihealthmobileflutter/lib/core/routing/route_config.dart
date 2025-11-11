import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/role_guard.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/register/cubits/register_cubit.dart';

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

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminReports = '/admin/reports';

  // Teacher routes
  static const String teacherCourses = '/teacher/courses';
  static const String teacherStudents = '/teacher/students';
  static const String teacherAssignments = '/teacher/assignments';

  // Student routes
  static const String studentCourses = '/student/courses';
  static const String studentAssignments = '/student/assignments';
  static const String studentGrades = '/student/grades';

  // Coach routes
  static const String coachClients = '/coach/clients';
  static const String coachSessions = '/coach/sessions';
  static const String coachPrograms = '/coach/programs';

  // ==================== BUILD AUTH PAGES ====================
  static Widget buildAuthPage(String? routeName) {
    switch (routeName) {
      case register:
        return BlocProvider(
          create: (_) => RegisterCubit(
            registerUseCase: sl(),
            authenticationBloc: sl<AuthenticationBloc>(),
          ),
          //child: const RegisterScreen(),
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
          //child: const LoginScreen(),
        );
    }
  }

  // ==================== BUILD AUTHENTICATED PAGES ====================
  static Widget buildPage({
    required String routeName,
    required String? role,
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

      // ===== Admin Routes =====
      case adminDashboard:
        return _buildAdminDashboard(arguments);

      case adminUsers:
        return _buildAdminUsers(arguments);

      case adminReports:
        return _buildAdminReports(arguments);

      // ===== Teacher Routes =====
      case teacherCourses:
        return _buildTeacherCourses(arguments);

      case teacherStudents:
        return _buildTeacherStudents(arguments);

      case teacherAssignments:
        return _buildTeacherAssignments(arguments);

      // ===== Student Routes =====
      case studentCourses:
        return _buildStudentCourses(arguments);

      case studentAssignments:
        return _buildStudentAssignments(arguments);

      case studentGrades:
        return _buildStudentGrades(arguments);

      // ===== Coach Routes =====
      case coachClients:
        return _buildCoachClients(arguments);

      case coachSessions:
        return _buildCoachSessions(arguments);

      case coachPrograms:
        return _buildCoachPrograms(arguments);

      default:
        return _ErrorPage(message: 'Không tìm thấy trang: $routeName');
    }
  }

  // ==================== BUILD MAIN SCREEN BY ROLE ====================
  static Widget? _buildMainScreenByRole(String? role) {
    final normalizedRole = RoleGuard.getNormalizedRole(role);

    switch (normalizedRole) {
      case 'admin':
      // TODO: Return AdminMainScreen
      // return const MainScreen(); // Placeholder

      case 'coach':
      // TODO: Return CoachMainScreen
      // return const MainScreen(); // Placeholder

      case 'user':
      default:
      // return const MainScreen();
    }
  }

  // ==================== COMMON SCREENS ====================
  static Widget _buildProfileScreen(
    String? role,
    Map<String, dynamic>? arguments,
  ) {
    // TODO: Implement profile screen với custom layout theo role
    return const Scaffold(body: Center(child: Text('Profile Screen')));
  }

  static Widget _buildSettingsScreen(
    String? role,
    Map<String, dynamic>? arguments,
  ) {
    // TODO: Implement settings screen
    return const Scaffold(body: Center(child: Text('Settings Screen')));
  }

  // ==================== ADMIN SCREENS ====================
  static Widget _buildAdminDashboard(Map<String, dynamic>? arguments) {
    // TODO: Implement admin dashboard
    return const Scaffold(body: Center(child: Text('Admin Dashboard')));
  }

  static Widget _buildAdminUsers(Map<String, dynamic>? arguments) {
    // TODO: Implement admin users management
    return const Scaffold(body: Center(child: Text('Admin Users')));
  }

  static Widget _buildAdminReports(Map<String, dynamic>? arguments) {
    // TODO: Implement admin reports
    return const Scaffold(body: Center(child: Text('Admin Reports')));
  }

  // ==================== TEACHER SCREENS ====================
  static Widget _buildTeacherCourses(Map<String, dynamic>? arguments) {
    // TODO: Implement teacher courses
    return const Scaffold(body: Center(child: Text('Teacher Courses')));
  }

  static Widget _buildTeacherStudents(Map<String, dynamic>? arguments) {
    // TODO: Implement teacher students
    return const Scaffold(body: Center(child: Text('Teacher Students')));
  }

  static Widget _buildTeacherAssignments(Map<String, dynamic>? arguments) {
    // TODO: Implement teacher assignments
    return const Scaffold(body: Center(child: Text('Teacher Assignments')));
  }

  // ==================== STUDENT SCREENS ====================
  static Widget _buildStudentCourses(Map<String, dynamic>? arguments) {
    // TODO: Implement student courses
    return const Scaffold(body: Center(child: Text('Student Courses')));
  }

  static Widget _buildStudentAssignments(Map<String, dynamic>? arguments) {
    // TODO: Implement student assignments
    return const Scaffold(body: Center(child: Text('Student Assignments')));
  }

  static Widget _buildStudentGrades(Map<String, dynamic>? arguments) {
    // TODO: Implement student grades
    return const Scaffold(body: Center(child: Text('Student Grades')));
  }

  // ==================== COACH SCREENS ====================
  static Widget _buildCoachClients(Map<String, dynamic>? arguments) {
    // TODO: Implement coach clients
    return const Scaffold(body: Center(child: Text('Coach Clients')));
  }

  static Widget _buildCoachSessions(Map<String, dynamic>? arguments) {
    // TODO: Implement coach sessions
    return const Scaffold(body: Center(child: Text('Coach Sessions')));
  }

  static Widget _buildCoachPrograms(Map<String, dynamic>? arguments) {
    // TODO: Implement coach programs
    return const Scaffold(body: Center(child: Text('Coach Programs')));
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

  // Admin navigation
  static void navigateToAdminDashboard(BuildContext context) {
    Navigator.of(context).pushNamed(adminDashboard);
  }

  // Teacher navigation
  static void navigateToTeacherCourses(BuildContext context) {
    Navigator.of(context).pushNamed(teacherCourses);
  }

  // Student navigation
  static void navigateToStudentCourses(BuildContext context) {
    Navigator.of(context).pushNamed(studentCourses);
  }

  // Coach navigation
  static void navigateToCoachClients(BuildContext context) {
    Navigator.of(context).pushNamed(coachClients);
  }
}

// ==================== ERROR PAGES ====================

/// Trang hiển thị khi không đủ quyền
class _ForbiddenPage extends StatelessWidget {
  final String? role;
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
