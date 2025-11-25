import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/injection_container.dart' as di;
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_personal/personal_health_profile_screen.dart';

/// Health Profile Summary Screen

class HealthProfileSummaryScreen extends StatelessWidget {
  final HealthProfile profile;

  const HealthProfileSummaryScreen({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HealthProfileBloc>(),
      child: HealthProfileSummaryView(profile: profile),
    );
  }
}

class HealthProfileSummaryView extends StatefulWidget {
  final HealthProfile profile;

  const HealthProfileSummaryView({
    super.key,
    required this.profile,
  });

  @override
  State<HealthProfileSummaryView> createState() =>
      _HealthProfileSummaryViewState();
}

class _HealthProfileSummaryViewState extends State<HealthProfileSummaryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late HealthProfile _currentProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentProfile = widget.profile;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentProfile.checkupDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textLight,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _currentProfile.checkupDate) {
      // Reload profile by selected date
      setState(() {
        _currentProfile = _currentProfile.copyWith(checkupDate: picked);
      });
    }
  }

  void _handleUpdate(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PersonalHealthProfileScreen(existingProfile: _currentProfile),
      ),
    );

    if (result == true && mounted) {
      // Refresh profile after update
      context
          .read<HealthProfileBloc>()
          .add(GetHealthProfileByIdEvent(_currentProfile.id!));
    }
  }

  void _handleDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn muốn xóa hồ sơ sức khỏe này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<HealthProfileBloc>()
                  .add(DeleteHealthProfileEvent(_currentProfile.id!));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<HealthProfileBloc, HealthProfileState>(
          listener: (context, state) {
            if (state is HealthProfileDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xóa hồ sơ thành công'),
                  backgroundColor: AppColors.success,
                ),
              );
              // Pop back to home (empty state)
              Navigator.pop(context);
            } else if (state is HealthProfileLoaded) {
              setState(() {
                _currentProfile = state.profile;
              });
            } else if (state is HealthProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: Column(
            children: [
              // Header with checkup date
              _buildHeader(),
              // Tab Bar
              Container(
                color: AppColors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Summary'),
                    Tab(text: 'Fitness'),
                    Tab(text: 'Advance'),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(),
                    _buildFitnessTab(),
                    _buildAdvanceTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          GestureDetector(
            onTap: () => _selectCheckupDate(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Checkup Date',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy').format(_currentProfile.checkupDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Info Card
          _buildProfileInfoCard(),
          const SizedBox(height: 16),
          // Body Metrics
          _buildBodyMetricsCard(),
          const SizedBox(height: 16),
          // Body Measurements
          _buildBodyMeasurementsCard(),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleUpdate(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDelete(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // My Goal Section
          _buildMyGoalSection(),
        ],
      ),
    );
  }

  Widget _buildFitnessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fitness Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            if (_currentProfile.maxPushUps != null)
              _buildInfoRow('Max Push Ups', '${_currentProfile.maxPushUps}'),
            if (_currentProfile.maxWeightLifted != null)
              _buildInfoRow('Max Weight Lifted',
                  '${_currentProfile.maxWeightLifted} kg'),
            if (_currentProfile.activityLevel != null)
              _buildInfoRow(
                  'Activity Level', '${_currentProfile.activityLevel}/5'),
            if (_currentProfile.experienceLevel != null)
              _buildInfoRow('Experience Level',
                  _currentProfile.experienceLevel ?? '-'),
            if (_currentProfile.workoutFrequency != null)
              _buildInfoRow('Workout Frequency',
                  '${_currentProfile.workoutFrequency} days/week'),
          ]),
        ],
      ),
    );
  }

  Widget _buildAdvanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoCard([
            if (_currentProfile.restingHeartRate != null)
              _buildInfoRow('Resting Heart Rate',
                  '${_currentProfile.restingHeartRate} bpm'),
            if (_currentProfile.bloodPressure != null)
              _buildInfoRow(
                  'Blood Pressure',
                  '${_currentProfile.bloodPressure!.systolic}/${_currentProfile.bloodPressure!.diastolic} mmHg'),
            if (_currentProfile.cholesterol != null) ...[
              _buildInfoRow('Total Cholesterol',
                  '${_currentProfile.cholesterol!.total} mg/dL'),
              _buildInfoRow(
                  'HDL', '${_currentProfile.cholesterol!.hdl} mg/dL'),
              _buildInfoRow(
                  'LDL', '${_currentProfile.cholesterol!.ldl} mg/dL'),
            ],
            if (_currentProfile.bloodSugar != null)
              _buildInfoRow(
                  'Blood Sugar', '${_currentProfile.bloodSugar} mg/dL'),
            if (_currentProfile.healthStatus != null &&
                _currentProfile.healthStatus!.isNotEmpty)
              _buildInfoRow('Health Conditions',
                  _currentProfile.healthStatus!.join(', ')),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.gray200,
            child: const Icon(Icons.person, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Huynh Minh Tri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('Gender: Male',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                Text('Birthday: 11/09/2004    Age: 21',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                  'BMI', _currentProfile.bmi?.toStringAsFixed(0)),
              _buildMetricItem(
                  'WHR', _currentProfile.whr?.toStringAsFixed(2)),
              _buildMetricItem('BMR',
                  '${_currentProfile.bmr?.toStringAsFixed(0)}cal'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Body Fat',
                  '${_currentProfile.bodyFat?.toStringAsFixed(0)}%'),
              _buildMetricItem('Muscle Mass',
                  '${_currentProfile.muscleMass?.toStringAsFixed(0)}kg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMeasurementsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Neck: ${_currentProfile.neck?.toStringAsFixed(0)}cm'),
                const SizedBox(height: 8),
                Text('Waist: ${_currentProfile.waist?.toStringAsFixed(0)}cm'),
                const SizedBox(height: 8),
                Text('Hip: ${_currentProfile.hip?.toStringAsFixed(0)}cm'),
              ],
            ),
          ),
          Container(
            width: 100,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'H: ${_currentProfile.height?.toStringAsFixed(0)}cm',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const Icon(Icons.person_outline, size: 60),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'W: ${_currentProfile.weight?.toStringAsFixed(1)}kg',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String? value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value ?? '-',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMyGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('My Goal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'No goals set yet',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}