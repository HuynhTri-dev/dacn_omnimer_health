import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/injection_container.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/blocs/exercise_home_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/exercise/exercise_home/exercise_home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/health_profile_home_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/more/more_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_home/workout_home_screen.dart';

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
      const WorkoutHomeScreen(),
      const HealthProfileHomeScreen(),
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
    return Scaffold(
      // Body: Hiển thị trang tương ứng với index hiện tại
      body: _pages[_currentIndex],

      // Bottom Navigation Bar
      bottomNavigationBar: CurvedNavigationBar(
        // Index hiện tại
        index: _currentIndex,

        // Callback khi thay đổi tab
        onTap: _onTabChanged,

        // Màu nền của navigation bar
        backgroundColor: AppColors.background,

        // Màu của button đang active
        color: AppColors.white,

        // Màu của button đang active (nổi lên)
        buttonBackgroundColor: AppColors.primary,

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
            child: Icon(
              Icons.fitness_center,
              size: 26.sp,
              color: _currentIndex == 0
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            label: 'Exercise',
            labelStyle: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: _currentIndex == 0
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),

          // Workout tab
          CurvedNavigationBarItem(
            child: Icon(
              Icons.sports_gymnastics,
              size: 26.sp,
              color: _currentIndex == 1
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            label: 'Workout',
            labelStyle: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: _currentIndex == 1
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),

          // Health Profile tab
          CurvedNavigationBarItem(
            child: Icon(
              Icons.favorite,
              size: 26.sp,
              color: _currentIndex == 2
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            label: 'Health',
            labelStyle: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: _currentIndex == 2
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),

          // More tab
          CurvedNavigationBarItem(
            child: Icon(
              Icons.more_horiz,
              size: 26.sp,
              color: _currentIndex == 3
                  ? AppColors.white
                  : AppColors.textSecondary,
            ),
            label: 'More',
            labelStyle: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: _currentIndex == 3
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
