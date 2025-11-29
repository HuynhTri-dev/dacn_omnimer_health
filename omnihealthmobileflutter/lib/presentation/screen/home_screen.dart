import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/exercise_home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/blocs/workout_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/health_profile_page.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/more_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/workout_home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';

/// Màn hình Home chính với Bottom Navigation Bar
/// Quản lý 4 trang chính của ứng dụng:
/// 1. Exercise - Danh sách bài tập
/// 2. Workout - Kế hoạch tập luyện
/// 3. Health Profile - Thông tin sức khỏe
/// 4. More - Cài đặt và tùy chọn
///
/// Sử dụng CurvedNavigationBar để tạo bottom bar đẹp mắt
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index của trang hiện tại
  int _currentIndex = 0;

  // Danh sách các trang
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider(
        create: (_) => sl<ExerciseHomeBloc>()..add(LoadInitialData()),
        child: const ExerciseHomeScreen(),
      ),
      BlocProvider(
        create: (_) => sl<WorkoutHomeBloc>()..add(LoadInitialWorkoutData()),
        child: const WorkoutHomeScreen(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                sl<HealthProfileBloc>()
                  ..add(const GetLatestHealthProfileEvent()),
          ),
          BlocProvider(create: (_) => sl<GoalBloc>()),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<HealthProfileBloc, HealthProfileState>(
              listener: (context, state) {
                // When profile is loaded, load goals
                if (state is HealthProfileLoaded) {
                  final authState = context.read<AuthenticationBloc>().state;
                  if (authState is AuthenticationAuthenticated) {
                    context.read<HealthProfileBloc>().add(
                      GetHealthProfileGoalsEvent(authState.user.id),
                    );
                  }
                }
              },
            ),
          ],
          child: const HealthProfilePage(),
        ),
      ),
      const MoreScreen(),
    ];
  }

  /// Xử lý khi thay đổi tab
  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Body: Hiển thị trang tương ứng với index hiện tại
      body: _pages[_currentIndex],

      // Bottom Navigation Bar với shadow để làm nổi bật
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: CurvedNavigationBar(
          // Index hiện tại
          index: _currentIndex,

          // Callback khi thay đổi tab
          onTap: _onTabChanged,

          // Màu nền của navigation bar
          backgroundColor: theme.scaffoldBackgroundColor,

          // Màu của button đang active
          color: theme.cardColor,

          // Màu của button đang active (nổi lên)
          buttonBackgroundColor: theme.primaryColor,

          // Độ cao của navigation bar
          height: 60.h,

          // Animation duration
          animationDuration: const Duration(milliseconds: 300),

          // Animation curve
          animationCurve: Curves.easeInOut,

          // Danh sách các items
          items: [
            // Exercise tab
            CurvedNavigationBarItem(
              child: Container(
                decoration: _currentIndex == 0
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  Icons.fitness_center,
                  size: 26.sp,
                  color: _currentIndex == 0
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
              label: 'Exercise',
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: _currentIndex == 0
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color,
              ),
            ),

            // Workout tab
            CurvedNavigationBarItem(
              child: Container(
                decoration: _currentIndex == 1
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  Icons.sports_gymnastics,
                  size: 26.sp,
                  color: _currentIndex == 1
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
              label: 'Workout',
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: _currentIndex == 1
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color,
              ),
            ),

            // Health Profile tab
            CurvedNavigationBarItem(
              child: Container(
                decoration: _currentIndex == 2
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  Icons.favorite,
                  size: 26.sp,
                  color: _currentIndex == 2
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
              label: 'Health',
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: _currentIndex == 2
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color,
              ),
            ),

            // More tab
            CurvedNavigationBarItem(
              child: Container(
                decoration: _currentIndex == 3
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Icon(
                  Icons.more_horiz,
                  size: 26.sp,
                  color: _currentIndex == 3
                      ? theme.colorScheme.onPrimary
                      : theme.textTheme.bodySmall?.color,
                ),
              ),
              label: 'More',
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                color: _currentIndex == 3
                    ? theme.primaryColor
                    : theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
