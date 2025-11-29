import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/core/theme/app_theme.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/cubits/login_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/auth/login/login_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/home_screen.dart';
import 'package:receive_intent/receive_intent.dart' as ri;
import 'package:url_launcher/url_launcher.dart';

/// Global navigator key để có thể điều khiển navigation từ bất kỳ đâu
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  @override
  void initState() {
    super.initState();
    _checkIntent();
  }

  Future<void> _checkIntent() async {
    try {
      final ri.Intent? intent = await ri.ReceiveIntent.getInitialIntent();
      if (intent != null &&
          intent.action == 'android.intent.action.VIEW_PERMISSION_USAGE') {
        _openPrivacyPolicy();
      }
    } catch (e) {
      debugPrint("Error checking intent: $e");
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://doc-hosting.flycricket.io/omnimer-health-privacy-policy/37b589ac-7f6f-4ee9-9b0f-fb1ffabc4f04/privacy',
    );
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) {
        // Chỉ listen khi chuyển sang Unauthenticated (logout)
        return current is AuthenticationUnauthenticated &&
            previous is! AuthenticationUnauthenticated;
      },
      listener: (context, state) {
        debugPrint('AppView BlocListener: ${state.runtimeType}');
        if (state is AuthenticationUnauthenticated) {
          // Đợi frame tiếp theo để đảm bảo navigator đã sẵn sàng
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToLogin();
          });
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'OmniMer EDU',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthWrapper(),
            onGenerateRoute: (settings) {
              final authState = context.read<AuthenticationBloc>().state;
              if (authState is! AuthenticationAuthenticated) {
                return MaterialPageRoute(
                  builder: (_) => RouteConfig.buildAuthPage(settings.name),
                  settings: settings,
                );
              }
              return MaterialPageRoute(
                builder: (_) => RouteConfig.buildPage(
                  routeName: settings.name ?? RouteConfig.main,
                  role: authState.user.roleName,
                  arguments: settings.arguments as Map<String, dynamic>?,
                ),
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToLogin() {
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      debugPrint('Navigating to LoginScreen...');
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => LoginCubit(
              loginUseCase: sl(),
              authenticationBloc: sl<AuthenticationBloc>(),
            ),
            child: const LoginScreen(),
          ),
        ),
        (route) => false,
      );
    } else {
      debugPrint('Navigator is null!');
    }
  }
}

/// Wrapper để quản lý login/logout và routing tự động
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listenWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      listener: (context, state) {
        // Log state changes for debugging
        debugPrint('AuthWrapper state changed: ${state.runtimeType}');

        if (state is AuthenticationError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        debugPrint('AuthWrapper builder: ${state.runtimeType}');

        if (state is AuthenticationAuthenticated) {
          // User đã đăng nhập -> vào HomeScreen
          return const HomeScreen();
        } else if (state is AuthenticationUnauthenticated ||
            state is AuthenticationError) {
          // User chưa đăng nhập hoặc có lỗi -> LoginScreen
          return BlocProvider(
            create: (_) => LoginCubit(
              loginUseCase: sl(),
              authenticationBloc: sl<AuthenticationBloc>(),
            ),
            child: const LoginScreen(),
          );
        } else {
          // Loading state (AuthenticationInitial, AuthenticationLoading)
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60.w,
                    height: 60.h,
                    child: CircularProgressIndicator(strokeWidth: 4.w),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Đang tải...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
