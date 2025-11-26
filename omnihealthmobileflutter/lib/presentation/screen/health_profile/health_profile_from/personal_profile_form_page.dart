import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/health_profile/health_profile_entity.dart';
import 'package:omnihealthmobileflutter/injection_container.dart' as di;
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/bloc/health_profile_form_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/bloc/health_profile_form_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/bloc/health_profile_form_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/widgets/body_measurements_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/widgets/fitness_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/widgets/health_status_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_profile/health_profile_from/widgets/metrics_section.dart';

/// Trang form tạo/cập nhật Health Profile
/// - Nếu có profileId: Load và update profile
/// - Nếu không có profileId: Tạo profile mới
class PersonalProfileFormPage extends StatelessWidget {
  final String? profileId;
  final DateTime? initialDate;

  const PersonalProfileFormPage({super.key, this.profileId, this.initialDate});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<HealthProfileFormBloc>()
            ..add(LoadHealthProfileFormEvent(profileId: profileId)),
      child: _PersonalProfileFormView(initialDate: initialDate),
    );
  }
}

class _PersonalProfileFormView extends StatefulWidget {
  final DateTime? initialDate;
  const _PersonalProfileFormView({this.initialDate});

  @override
  State<_PersonalProfileFormView> createState() =>
      _PersonalProfileFormViewState();
}

class _PersonalProfileFormViewState extends State<_PersonalProfileFormView> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  bool _calculateAutomatically = false;
  bool _hasMedicalData = false;
  ExperienceLevelEnum? _selectedExperienceLevel;
  ActivityLevelEnum? _selectedActivityLevel;

  // Health Status State
  List<String> _knownConditions = [];
  Map<String, String> _knownConditionsDetails = {};

  List<String> _painLocations = [];
  Map<String, String> _painLocationsDetails = {};

  List<String> _jointIssues = [];
  Map<String, String> _jointIssuesDetails = {};

  List<String> _injuries = [];
  Map<String, String> _injuriesDetails = {};

  List<String> _abnormalities = [];
  Map<String, String> _abnormalitiesDetails = {};

  final TextEditingController _notesController = TextEditingController();

  // Health Status Options (Mock Data - Replace with actual data source if needed)
  final List<String> _knownConditionsOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Asthma',
    'Arthritis',
    'Obesity',
  ];
  final List<String> _painLocationsOptions = [
    'Head',
    'Neck',
    'Shoulders',
    'Back',
    'Lower Back',
    'Knees',
    'Ankles',
    'Feet',
  ];
  final List<String> _jointIssuesOptions = [
    'Stiffness',
    'Swelling',
    'Redness',
    'Warmth',
    'Limited Range of Motion',
  ];
  final List<String> _injuriesOptions = [
    'Fracture',
    'Sprain',
    'Strain',
    'Dislocation',
    'Concussion',
  ];
  final List<String> _abnormalitiesOptions = [
    'Scoliosis',
    'Kyphosis',
    'Lordosis',
    'Flat Feet',
  ];

  // Controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _hipController = TextEditingController();

  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _bmrController = TextEditingController();
  final TextEditingController _whrController = TextEditingController();
  final TextEditingController _bodyFatController = TextEditingController();
  final TextEditingController _muscleMassController = TextEditingController();

  final TextEditingController _maxPushUpsController = TextEditingController();
  final TextEditingController _maxWeightLiftedController =
      TextEditingController();
  final TextEditingController _workoutFrequencyController =
      TextEditingController();

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
    _workoutFrequencyController.dispose();
    _restingHeartRateController.dispose();
    _bloodPressureSystolicController.dispose();
    _bloodPressureDiastolicController.dispose();
    _cholesterolTotalController.dispose();
    _cholesterolHdlController.dispose();
    _cholesterolLdlController.dispose();
    _bloodSugarController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _parseDetailedList(
    List<String> source,
    List<String> targetKeys,
    Map<String, String> targetDetails,
  ) {
    targetKeys.clear();
    targetDetails.clear();
    for (var item in source) {
      final parts = item.split(': ');
      final key = parts[0];
      targetKeys.add(key);
      if (parts.length > 1) {
        targetDetails[key] = parts.sublist(1).join(': ');
      }
    }
  }

  List<String> _combineDetailedList(
    List<String> keys,
    Map<String, String> details,
  ) {
    return keys.map((key) {
      final detail = details[key];
      if (detail != null && detail.isNotEmpty) {
        return '$key: $detail';
      }
      return key;
    }).toList();
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
    _maxWeightLiftedController.text = profile.maxWeightLifted?.toString() ?? '';
    _selectedActivityLevel = ActivityLevelEnum.fromValue(profile.activityLevel);
    _selectedExperienceLevel = profile.experienceLevel;
    _workoutFrequencyController.text =
        profile.workoutFrequency?.toString() ?? '';
    _restingHeartRateController.text =
        profile.restingHeartRate?.toString() ?? '';
    _bloodSugarController.text = profile.bloodSugar?.toString() ?? '';

    if (profile.healthStatus != null) {
      _parseDetailedList(
        profile.healthStatus!.knownConditions,
        _knownConditions,
        _knownConditionsDetails,
      );
      _parseDetailedList(
        profile.healthStatus!.painLocations,
        _painLocations,
        _painLocationsDetails,
      );
      _parseDetailedList(
        profile.healthStatus!.jointIssues,
        _jointIssues,
        _jointIssuesDetails,
      );
      _parseDetailedList(
        profile.healthStatus!.injuries,
        _injuries,
        _injuriesDetails,
      );
      _parseDetailedList(
        profile.healthStatus!.abnormalities,
        _abnormalities,
        _abnormalitiesDetails,
      );
      _notesController.text = profile.healthStatus!.notes ?? '';
    }

    if (profile.bloodPressure != null) {
      _bloodPressureSystolicController.text = profile.bloodPressure!.systolic
          .toString();
      _bloodPressureDiastolicController.text = profile.bloodPressure!.diastolic
          .toString();
    }

    if (profile.cholesterol != null) {
      _cholesterolTotalController.text = profile.cholesterol!.total.toString();
      _cholesterolHdlController.text = profile.cholesterol!.hdl.toString();
      _cholesterolLdlController.text = profile.cholesterol!.ldl.toString();
    }

    // Check if any medical data exists to enable the section
    if (profile.restingHeartRate != null ||
        profile.bloodPressure != null ||
        profile.cholesterol != null ||
        profile.bloodSugar != null ||
        (profile.healthStatus != null && profile.healthStatus!.isNotEmpty)) {
      _hasMedicalData = true;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleSubmit(BuildContext context, HealthProfile? existingProfile) {
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
    Cholesterol? cholesterol;
    int? restingHeartRate;
    double? bloodSugar;
    HealthStatus? healthStatus;

    // Only process medical data if enabled
    if (_hasMedicalData) {
      if (_bloodPressureSystolicController.text.isNotEmpty &&
          _bloodPressureDiastolicController.text.isNotEmpty) {
        bloodPressure = BloodPressure(
          systolic: int.parse(_bloodPressureSystolicController.text),
          diastolic: int.parse(_bloodPressureDiastolicController.text),
        );
      }

      if (_cholesterolTotalController.text.isNotEmpty &&
          _cholesterolHdlController.text.isNotEmpty &&
          _cholesterolLdlController.text.isNotEmpty) {
        cholesterol = Cholesterol(
          total: double.parse(_cholesterolTotalController.text),
          hdl: double.parse(_cholesterolHdlController.text),
          ldl: double.parse(_cholesterolLdlController.text),
        );
      }

      restingHeartRate = int.tryParse(_restingHeartRateController.text);
      bloodSugar = double.tryParse(_bloodSugarController.text);

      healthStatus = HealthStatus(
        knownConditions: _combineDetailedList(
          _knownConditions,
          _knownConditionsDetails,
        ),
        painLocations: _combineDetailedList(
          _painLocations,
          _painLocationsDetails,
        ),
        jointIssues: _combineDetailedList(_jointIssues, _jointIssuesDetails),
        injuries: _combineDetailedList(_injuries, _injuriesDetails),
        abnormalities: _combineDetailedList(
          _abnormalities,
          _abnormalitiesDetails,
        ),
        notes: _notesController.text,
      );
    }

    final profile = HealthProfile(
      id: existingProfile?.id,
      userId: existingProfile?.userId,
      checkupDate: _selectedDate,
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      waist: double.tryParse(_waistController.text),
      neck: double.tryParse(_neckController.text),
      hip: double.tryParse(_hipController.text),
      bmi: _calculateAutomatically
          ? null
          : double.tryParse(_bmiController.text),
      bmr: _calculateAutomatically
          ? null
          : double.tryParse(_bmrController.text),
      whr: _calculateAutomatically
          ? null
          : double.tryParse(_whrController.text),
      bodyFat: _calculateAutomatically
          ? null
          : double.tryParse(_bodyFatController.text),
      muscleMass: _calculateAutomatically
          ? null
          : double.tryParse(_muscleMassController.text),
      maxPushUps: int.tryParse(_maxPushUpsController.text),
      maxWeightLifted: double.tryParse(_maxWeightLiftedController.text),
      activityLevel: _selectedActivityLevel?.value,
      experienceLevel: _selectedExperienceLevel,
      workoutFrequency: int.tryParse(_workoutFrequencyController.text),
      restingHeartRate: restingHeartRate,
      bloodPressure: bloodPressure,
      cholesterol: cholesterol,
      bloodSugar: bloodSugar,
      healthStatus: healthStatus,
    );

    context.read<HealthProfileFormBloc>().add(
      SubmitHealthProfileFormEvent(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      body: BlocConsumer<HealthProfileFormBloc, HealthProfileFormState>(
        listener: (context, state) {
          if (state is HealthProfileFormLoaded && state.profile != null) {
            setState(() {
              _populateExistingData(state.profile!);
            });
          } else if (state is HealthProfileFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isUpdate
                      ? 'Profile updated successfully'
                      : 'Profile created successfully',
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is HealthProfileFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HealthProfileFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final existingProfile = state is HealthProfileFormLoaded
              ? state.profile
              : null;

          return SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.md.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMeasurementsSection(
                  heightController: _heightController,
                  weightController: _weightController,
                  waistController: _waistController,
                  neckController: _neckController,
                  hipController: _hipController,
                ),
                SizedBox(height: AppSpacing.md.h),
                MetricsSection(
                  calculateAutomatically: _calculateAutomatically,
                  onCalculateAutomaticallyChanged: (value) {
                    setState(() {
                      _calculateAutomatically = value;
                    });
                  },
                  bmiController: _bmiController,
                  bmrController: _bmrController,
                  whrController: _whrController,
                  bodyFatController: _bodyFatController,
                  muscleMassController: _muscleMassController,
                ),
                SizedBox(height: AppSpacing.md.h),
                FitnessSection(
                  maxPushUpsController: _maxPushUpsController,
                  maxWeightLiftedController: _maxWeightLiftedController,
                  selectedActivityLevel: _selectedActivityLevel,
                  onActivityLevelChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                  selectedExperienceLevel: _selectedExperienceLevel,
                  onExperienceLevelChanged: (value) {
                    setState(() {
                      _selectedExperienceLevel = value;
                    });
                  },
                  workoutFrequencyController: _workoutFrequencyController,
                ),
                SizedBox(height: AppSpacing.md.h),
                HealthStatusSection(
                  restingHeartRateController: _restingHeartRateController,
                  bloodPressureSystolicController:
                      _bloodPressureSystolicController,
                  bloodPressureDiastolicController:
                      _bloodPressureDiastolicController,
                  cholesterolTotalController: _cholesterolTotalController,
                  cholesterolHdlController: _cholesterolHdlController,
                  cholesterolLdlController: _cholesterolLdlController,
                  bloodSugarController: _bloodSugarController,

                  // Detailed Health Status Props
                  knownConditionsSelected: _knownConditions,
                  knownConditionsDetails: _knownConditionsDetails,
                  knownConditionsOptions: _knownConditionsOptions,
                  onKnownConditionsSelectionChanged: (values) {
                    setState(() {
                      _knownConditions = values;
                    });
                  },
                  onKnownConditionsDetailChanged: (key, detail) {
                    setState(() {
                      _knownConditionsDetails[key] = detail;
                    });
                  },

                  painLocationsSelected: _painLocations,
                  painLocationsDetails: _painLocationsDetails,
                  painLocationsOptions: _painLocationsOptions,
                  onPainLocationsSelectionChanged: (values) {
                    setState(() {
                      _painLocations = values;
                    });
                  },
                  onPainLocationsDetailChanged: (key, detail) {
                    setState(() {
                      _painLocationsDetails[key] = detail;
                    });
                  },

                  jointIssuesSelected: _jointIssues,
                  jointIssuesDetails: _jointIssuesDetails,
                  jointIssuesOptions: _jointIssuesOptions,
                  onJointIssuesSelectionChanged: (values) {
                    setState(() {
                      _jointIssues = values;
                    });
                  },
                  onJointIssuesDetailChanged: (key, detail) {
                    setState(() {
                      _jointIssuesDetails[key] = detail;
                    });
                  },

                  injuriesSelected: _injuries,
                  injuriesDetails: _injuriesDetails,
                  injuriesOptions: _injuriesOptions,
                  onInjuriesSelectionChanged: (values) {
                    setState(() {
                      _injuries = values;
                    });
                  },
                  onInjuriesDetailChanged: (key, detail) {
                    setState(() {
                      _injuriesDetails[key] = detail;
                    });
                  },

                  abnormalitiesSelected: _abnormalities,
                  abnormalitiesDetails: _abnormalitiesDetails,
                  abnormalitiesOptions: _abnormalitiesOptions,
                  onAbnormalitiesSelectionChanged: (values) {
                    setState(() {
                      _abnormalities = values;
                    });
                  },
                  onAbnormalitiesDetailChanged: (key, detail) {
                    setState(() {
                      _abnormalitiesDetails[key] = detail;
                    });
                  },

                  notesController: _notesController,
                  hasMedicalData: _hasMedicalData,
                  onHasMedicalDataChanged: (value) {
                    setState(() {
                      _hasMedicalData = value;
                    });
                  },
                ),
                SizedBox(height: AppSpacing.xl.h),
                ButtonPrimary(
                  title: existingProfile != null
                      ? 'Update Profile'
                      : 'Create Profile',
                  onPressed: state is HealthProfileFormSubmitting
                      ? null
                      : () => _handleSubmit(context, existingProfile),
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
