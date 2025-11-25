import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/injection_container.dart' as di;
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_home/bloc/health_profile_state.dart';

class PersonalHealthProfileScreen extends StatelessWidget {
  final HealthProfile? existingProfile;

  const PersonalHealthProfileScreen({
    super.key,
    this.existingProfile,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<HealthProfileBloc>(),
      child: PersonalHealthProfileView(existingProfile: existingProfile),
    );
  }
}

class PersonalHealthProfileView extends StatefulWidget {
  final HealthProfile? existingProfile;

  const PersonalHealthProfileView({
    super.key,
    this.existingProfile,
  });

  @override
  State<PersonalHealthProfileView> createState() =>
      _PersonalHealthProfileViewState();
}

class _PersonalHealthProfileViewState extends State<PersonalHealthProfileView> {
  DateTime _selectedDate = DateTime.now();
  bool _calculateAutomatically = false;
  String? _selectedExperienceLevel;
  List<String> _selectedHealthStatuses = [];

  // Experience Level Options
  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert'
  ];

  // Health Status Options
  final List<String> _healthStatusOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Arthritis',
    'Obesity',
    'Healthy'
  ];

  // Controllers for Body Measurements
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  // Controllers for Metrics
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _bmrController = TextEditingController();
  final TextEditingController _whrController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();

  // Controllers for Fitness
  final TextEditingController _maxPushUpsController = TextEditingController();
  final TextEditingController _maxWeightLiftedController =
      TextEditingController();
  final TextEditingController _activityLevelController =
      TextEditingController();
  final TextEditingController _workoutFrequencyController =
      TextEditingController();

  // Controllers for Health Status
  final TextEditingController _restingHeartRateController =
      TextEditingController();
  final TextEditingController _bloodPressureSystolicController =
      TextEditingController();
  final TextEditingController _bloodPressureDiastolicController =
      TextEditingController();
  final TextEditingController _cholesterolTotalController =
      TextEditingController();
  final TextEditingController _cholesterolHdlController =
      TextEditingController();
  final TextEditingController _cholesterolLdlController =
      TextEditingController();
  final TextEditingController _bloodSugarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _populateExistingData(widget.existingProfile!);
    }
  }

  void _populateExistingData(HealthProfile profile) {
    _selectedDate = profile.checkupDate;
    _heightController.text = profile.height?.toString() ?? '';
    _weightController.text = profile.weight?.toString() ?? '';
    _waistController.text = profile.waist?.toString() ?? '';
    _neckController.text = profile.neck?.toString() ?? '';
    _hipController.text = profile.hip?.toString() ?? '';
    _bmiController.text = profile.bmi?.toString() ?? '';
    _bmrController.text = profile.bmr?.toString() ?? '';
    _whrController.text = profile.whr?.toString() ?? '';
    _bodyFatController.text = profile.bodyFat?.toString() ?? '';
    _muscleMassController.text = profile.muscleMass?.toString() ?? '';
    _maxPushUpsController.text = profile.maxPushUps?.toString() ?? '';
    _maxWeightLiftedController.text =
        profile.maxWeightLifted?.toString() ?? '';
    _activityLevelController.text = profile.activityLevel?.toString() ?? '';
    _selectedExperienceLevel = profile.experienceLevel;
    _workoutFrequencyController.text =
        profile.workoutFrequency?.toString() ?? '';
    _restingHeartRateController.text =
        profile.restingHeartRate?.toString() ?? '';
    _bloodSugarController.text = profile.bloodSugar?.toString() ?? '';
    _selectedHealthStatuses = profile.healthStatus ?? [];

    if (profile.bloodPressure != null) {
      _bloodPressureSystolicController.text =
          profile.bloodPressure!.systolic.toString();
      _bloodPressureDiastolicController.text =
          profile.bloodPressure!.diastolic.toString();
    }

    if (profile.cholesterol != null) {
      _cholesterolTotalController.text =
          profile.cholesterol!.total.toString();
      _cholesterolHdlController.text = profile.cholesterol!.hdl.toString();
      _cholesterolLdlController.text = profile.cholesterol!.ldl.toString();
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipController.dispose();
    _bmiController.dispose();
    _bmrController.dispose();
    _whrController.dispose();
    _bodyFatController.dispose();
    _muscleMassController.dispose();
    _maxPushUpsController.dispose();
    _maxWeightLiftedController.dispose();
    _activityLevelController.dispose();
    _workoutFrequencyController.dispose();
    _restingHeartRateController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _cholesterolTotalController.dispose();
    _cholesterolHdlController.dispose();
    _cholesterolLdlController.dispose();
    _bloodSugarController.dispose();
    super.dispose();
  }
  

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _calculateMetrics() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final waist = double.tryParse(_waistController.text);
    final hip = double.tryParse(_hipController.text);
    final neck = double.tryParse(_neckController.text);

    if (height != null && weight != null) {
      // Calculate BMI
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);
      _bmiController.text = bmi.toStringAsFixed(2);

      // Calculate BMR (Mifflin-St Jeor Equation for men)
      final bmr = 10 * weight + 6.25 * height - 5 * 25 + 5;
      _bmrController.text = bmr.toStringAsFixed(0);
    }

    if (waist != null && hip != null && hip > 0) {
      // Calculate WHR
      final whr = waist / hip;
      _whrController.text = whr.toStringAsFixed(2);
    }

    // Estimate Body Fat (Navy Method - requires height, waist, neck)
    if (height != null && waist != null && neck != null) {
      final bodyFatPercentage =
          495 / (1.0324 - 0.19077 * (waist - neck) + 0.15456 * height) - 450;
      _bodyFatController.text = bodyFatPercentage.toStringAsFixed(1);
    }

    // Estimate Muscle Mass
    if (weight != null && _bodyFatController.text.isNotEmpty) {
      final bodyFat = double.tryParse(_bodyFatController.text);
      if (bodyFat != null) {
        final muscleMass = weight * (1 - bodyFat / 100);
        _muscleMassController.text = muscleMass.toStringAsFixed(1);
      }
    }
  }

  void _showExperienceLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Experience Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _experienceLevels.map((level) {
            return RadioListTile<String>(
              title: Text(level),
              value: level,
              groupValue: _selectedExperienceLevel,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _selectedExperienceLevel = value;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showHealthStatusDialog() {
    List<String> tempSelected = List.from(_selectedHealthStatuses);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Select Health Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _healthStatusOptions.map((status) {
                return CheckboxListTile(
                  title: Text(status),
                  value: tempSelected.contains(status),
                  activeColor: AppColors.primary,
                  onChanged: (checked) {
                    setDialogState(() {
                      if (checked == true) {
                        tempSelected.add(status);
                      } else {
                        tempSelected.remove(status);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedHealthStatuses = tempSelected;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCreateOrUpdate() {
    // Validate required fields
    if (_heightController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Height and Weight are required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    BloodPressure? bloodPressure;
    if (_bloodPressureSystolicController.text.isNotEmpty &&
        _bloodPressureDiastolicController.text.isNotEmpty) {
      bloodPressure = BloodPressure(
        systolic: int.parse(_bloodPressureSystolicController.text),
        diastolic: int.parse(_bloodPressureDiastolicController.text),
      );
    }

    Cholesterol? cholesterol;
    if (_cholesterolTotalController.text.isNotEmpty &&
        _cholesterolHdlController.text.isNotEmpty &&
        _cholesterolLdlController.text.isNotEmpty) {
      cholesterol = Cholesterol(
        total: double.parse(_cholesterolTotalController.text),
        hdl: double.parse(_cholesterolHdlController.text),
        ldl: double.parse(_cholesterolLdlController.text),
      );
    }

    final profile = HealthProfile(
      id: widget.existingProfile?.id,
      userId: widget.existingProfile?.userId,
      checkupDate: _selectedDate,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      waist: double.tryParse(_waistController.text),
      neck: double.tryParse(_neckController.text),
      hip: double.tryParse(_hipController.text),
      bmi: double.tryParse(_bmiController.text),
      bmr: double.tryParse(_bmrController.text),
      whr: double.tryParse(_whrController.text),
      bodyFat: double.tryParse(_bodyFatController.text),
      muscleMass: double.tryParse(_muscleMassController.text),
      maxPushUps: int.tryParse(_maxPushUpsController.text),
      maxWeightLifted: double.tryParse(_maxWeightLiftedController.text),
      activityLevel: int.tryParse(_activityLevelController.text),
      experienceLevel: _selectedExperienceLevel,
      workoutFrequency: int.tryParse(_workoutFrequencyController.text),
      restingHeartRate: int.tryParse(_restingHeartRateController.text),
      bloodPressure: bloodPressure,
      cholesterol: cholesterol,
      bloodSugar: double.tryParse(_bloodSugarController.text),
      healthStatus:
          _selectedHealthStatuses.isEmpty ? null : _selectedHealthStatuses,
    );

    if (widget.existingProfile != null) {
      context
          .read<HealthProfileBloc>()
          .add(UpdateHealthProfileEvent(widget.existingProfile!.id!, profile));
    } else {
      context.read<HealthProfileBloc>().add(CreateHealthProfileEvent(profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Personal Health Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                    DateFormat('dd/MM/yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocListener<HealthProfileBloc, HealthProfileState>(
        listener: (context, state) {
          if (state is HealthProfileCreateSuccess ||
              state is HealthProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state is HealthProfileCreateSuccess
                      ? 'Profile created successfully'
                      : 'Profile updated successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is HealthProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<HealthProfileBloc, HealthProfileState>(
          builder: (context, state) {
            if (state is HealthProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Body Measurements Section
                  _buildSectionTitle('Body Measurements'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildInputField('Height (cm)', _heightController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child:
                            _buildInputField('Weight (kg)', _weightController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _buildInputField('Waist (cm)', _waistController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField('Neck (cm)', _neckController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('Hip (cm)', _hipController),

                  const SizedBox(height: 24),

                  // Metrics Section
                  _buildSectionTitle('Metrics'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _calculateAutomatically,
                        onChanged: (value) {
                          setState(() {
                            _calculateAutomatically = value ?? false;
                            if (_calculateAutomatically) {
                              _calculateMetrics();
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        'Calculate automatically',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'BMI',
                          _bmiController,
                          enabled: !_calculateAutomatically,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'BMR',
                          _bmrController,
                          enabled: !_calculateAutomatically,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'WHR',
                          _whrController,
                          enabled: !_calculateAutomatically,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'Body Fat (%)',
                          _bodyFatController,
                          enabled: !_calculateAutomatically,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                    'Muscle Mass',
                    _muscleMassController,
                    enabled: !_calculateAutomatically,
                  ),

                  const SizedBox(height: 24),

                  // Fitness & Physical Performance Section
                  _buildSectionTitle('Fitness & Physical Performance'),
                  const SizedBox(height: 12),
                  _buildInputField('Max Push Ups', _maxPushUpsController),
                  const SizedBox(height: 12),
                  _buildInputField(
                      'Max Weight Lifted (kg)', _maxWeightLiftedController),
                  const SizedBox(height: 12),
                  _buildInputField(
                      'Activity Level (1-5)', _activityLevelController),
                  const SizedBox(height: 12),
                  _buildSelectField(
                    'Experience Level',
                    _selectedExperienceLevel ?? 'Select',
                    _showExperienceLevelDialog,
                  ),
                  const SizedBox(height: 12),
                  _buildInputField('Workout Frequency (days/week)',
                      _workoutFrequencyController),

                  const SizedBox(height: 24),

                  // Health Status Section
                  _buildSectionTitle('Health Status'),
                  const SizedBox(height: 12),
                  _buildInputField(
                      'Resting Heart Rate (bpm)', _restingHeartRateController),
                  const SizedBox(height: 12),
                  _buildSectionTitle('Blood Pressure'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                            'Systolic', _bloodPressureSystolicController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                            'Diastolic', _bloodPressureDiastolicController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildSectionTitle('Cholesterol'),
                  const SizedBox(height: 8),
                  _buildInputField('Total', _cholesterolTotalController),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                            'HDL', _cholesterolHdlController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                            'LDL', _cholesterolLdlController),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(
                      'Blood Sugar (mg/dL)', _bloodSugarController),
                  const SizedBox(height: 12),
                  _buildSelectField(
                    'Health Status',
                    _selectedHealthStatuses.isEmpty
                        ? 'Select Conditions'
                        : _selectedHealthStatuses.join(', '),
                    _showHealthStatusDialog,
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.primary, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          onPressed: () {
                            if (_calculateAutomatically) {
                              _calculateMetrics();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _handleCreateOrUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            widget.existingProfile != null
                                ? 'Update'
                                : 'Create',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? AppColors.white : AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.create_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 14,
                color: enabled ? AppColors.textPrimary : AppColors.textMuted,
              ),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color:
                      enabled ? AppColors.textMuted : AppColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectField(
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.arrow_drop_down,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value == 'Select' || value == 'Select Conditions'
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}