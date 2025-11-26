import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/core/constants/enum_constant.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_state.dart';
import 'package:omnihealthmobileflutter/presentation/common/button/button_primary.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/bloc/goal_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/goal_details_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/frequency_section.dart';
import 'package:omnihealthmobileflutter/presentation/screen/goal/widgets/target_metrics_section.dart';

class GoalFormScreen extends StatefulWidget {
  final String? goalId;
  final GoalEntity? existingGoal;

  const GoalFormScreen({super.key, this.goalId, this.existingGoal});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Goal Fields
  GoalTypeEnum? _goalType;
  DateTime? _startDate;
  DateTime? _endDate;

  // Repeat Fields
  String? _frequency;
  final TextEditingController _intervalController = TextEditingController();
  List<int> _daysOfWeek = [];

  // Target Metrics
  List<TargetMetricEntity> _targetMetrics = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    if (widget.existingGoal != null) {
      final goal = widget.existingGoal!;
      _goalType = goal.goalType;
      _startDate = goal.startDate;
      _endDate = goal.endDate;

      if (goal.repeat != null) {
        _frequency = goal.repeat!.frequency;
        _intervalController.text = goal.repeat!.interval?.toString() ?? '';
        _daysOfWeek = goal.repeat!.daysOfWeek ?? [];
      }

      _targetMetrics = List.from(goal.targetMetric);
    } else {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 30));
      _targetMetrics.add(const TargetMetricEntity(metricName: '', value: 0));
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;

    if (_startDate == null || _endDate == null) {
      _showError('Please select start and end dates');
      return;
    }

    if (_targetMetrics.isEmpty) {
      _showError('Please add at least one target metric');
      return;
    }

    for (var metric in _targetMetrics) {
      if (metric.metricName.isEmpty || metric.value <= 0) {
        _showError('Please fill in all metric fields correctly');
        return;
      }
    }

    final userId = _getUserId();
    if (userId == null || userId.isEmpty) {
      _showError('User not authenticated. UserId: ${userId ?? "null"}');
      return;
    }

    final goal = _buildGoalEntity(userId);
    _submitGoal(goal);
  }

  String? _getUserId() {
    if (widget.existingGoal != null) {
      return widget.existingGoal!.userId;
    }

    final authState = context.read<AuthenticationBloc>().state;
    if (authState is AuthenticationAuthenticated) {
      return authState.user.id;
    }

    return null;
  }

  GoalEntity _buildGoalEntity(String userId) {
    RepeatMetadataEntity? repeat;
    if (_frequency != null) {
      repeat = RepeatMetadataEntity(
        frequency: _frequency!,
        interval: int.tryParse(_intervalController.text),
        daysOfWeek: _frequency == 'weekly' ? _daysOfWeek : null,
      );
    }

    return GoalEntity(
      id: widget.goalId ?? widget.existingGoal?.id,
      userId: userId,
      goalType: _goalType!,
      startDate: _startDate!,
      endDate: _endDate!,
      repeat: repeat,
      targetMetric: _targetMetrics,
    );
  }

  void _submitGoal(GoalEntity goal) {
    if (widget.goalId != null || widget.existingGoal != null) {
      context.read<GoalBloc>().add(UpdateGoalEvent(goal));
    } else {
      context.read<GoalBloc>().add(CreateGoalEvent(goal));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  void _addMetric() {
    setState(() {
      _targetMetrics.add(const TargetMetricEntity(metricName: '', value: 0));
    });
  }

  void _removeMetric(int index) {
    setState(() {
      _targetMetrics.removeAt(index);
    });
  }

  void _updateMetric(int index, {String? name, double? value, String? unit}) {
    setState(() {
      final old = _targetMetrics[index];
      _targetMetrics[index] = TargetMetricEntity(
        metricName: name ?? old.metricName,
        value: value ?? old.value,
        unit: unit ?? old.unit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.goalId != null || widget.existingGoal != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isUpdate ? 'Update Goal' : 'Create New Goal',
          style: AppTypography.h4,
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Operation successful')),
            );
            Navigator.pop(context, true);
          } else if (state is GoalError) {
            _showError(state.message);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GoalDetailsSection(
                  goalType: _goalType,
                  startDate: _startDate,
                  endDate: _endDate,
                  onGoalTypeChanged: (val) => setState(() => _goalType = val),
                  onStartDateChanged: (val) => setState(() => _startDate = val),
                  onEndDateChanged: (val) => setState(() => _endDate = val),
                ),
                SizedBox(height: AppSpacing.xl.h),
                FrequencySection(
                  frequency: _frequency,
                  intervalController: _intervalController,
                  daysOfWeek: _daysOfWeek,
                  onFrequencyChanged: (val) => setState(() => _frequency = val),
                  onDaysOfWeekChanged: (val) =>
                      setState(() => _daysOfWeek = val),
                ),
                SizedBox(height: AppSpacing.xl.h),
                TargetMetricsSection(
                  metrics: _targetMetrics,
                  onAddMetric: _addMetric,
                  onUpdateMetric: _updateMetric,
                  onRemoveMetric: _removeMetric,
                ),
                SizedBox(height: AppSpacing.xxl.h),
                ButtonPrimary(
                  title: isUpdate ? 'Update Goal' : 'Create Goal',
                  onPressed: _onSave,
                ),
                SizedBox(height: AppSpacing.xl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
