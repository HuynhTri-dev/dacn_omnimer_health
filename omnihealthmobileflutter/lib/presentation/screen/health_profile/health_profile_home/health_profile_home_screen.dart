import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/injection_container.dart' as di;
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_personal/personal_health_profile_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_menu/health_profile_summary_screen.dart';

class HealthProfileHomeScreen extends StatelessWidget {
  const HealthProfileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HealthProfileBloc>()
        ..add(const GetLatestHealthProfileEvent()),
      child: const HealthProfileHomeView(),
    );
  }
}

class HealthProfileHomeView extends StatefulWidget {
  const HealthProfileHomeView({super.key});

  @override
  State<HealthProfileHomeView> createState() => _HealthProfileHomeViewState();
}

class _HealthProfileHomeViewState extends State<HealthProfileHomeView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<HealthProfileBloc, HealthProfileState>(
        listener: (context, state) {
          if (state is HealthProfileCreateSuccess) {
            // After creating profile successfully, reload to show summary
            context
                .read<HealthProfileBloc>()
                .add(const GetLatestHealthProfileEvent());
          }
        },
        builder: (context, state) {
          if (state is HealthProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HealthProfileLoaded) {
            // User has profile -> Show Summary Screen
            return HealthProfileSummaryScreen(profile: state.profile);
          }

          if (state is HealthProfileError) {
            // No profile found or error -> Show empty state
            return _buildEmptyState();
          }

          // Initial state -> Show empty state
          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildTabNavigation(),
          Expanded(
            child: _selectedTab == 0 ? _buildGeneralTab() : Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Checkup Date',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '04/11/2025',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTab('Summary', 0),
          const SizedBox(width: 12),
          _buildTab('Fitness', 1),
          const SizedBox(width: 12),
          _buildTab('Advance', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textLight : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAddHealthInfoCard(),
          const SizedBox(height: 24),
          _buildMyGoalSection(),
        ],
      ),
    );
  }

  Widget _buildAddHealthInfoCard() {
    return GestureDetector(
      onTap: () async {
        // Navigate to create profile screen
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalHealthProfileScreen(),
          ),
        );

        // If profile created successfully, reload
        if (result == true && mounted) {
          context
              .read<HealthProfileBloc>()
              .add(const GetLatestHealthProfileEvent());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Add your health information to start tracking your progress today.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.add, color: AppColors.textLight, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Goal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Setting your goal to follow',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.textLight,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
