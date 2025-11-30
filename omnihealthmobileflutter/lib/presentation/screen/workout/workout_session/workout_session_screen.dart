import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/routing/route_config.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_state.dart';

part 'widgets/workout_session_header.dart';
part 'widgets/active_exercise_card.dart';
part 'widgets/active_set_row.dart';
part 'widgets/rest_timer_row.dart';
part 'widgets/workout_session_bottom_bar.dart';

class WorkoutSessionScreen extends StatefulWidget {
  final WorkoutTemplateEntity template;

  const WorkoutSessionScreen({super.key, required this.template});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  @override
  void initState() {
    super.initState();
    // Start the workout session
    context.read<WorkoutSessionBloc>().add(StartWorkoutEvent(widget.template));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
            listener: (context, state) {
              if (state.status == WorkoutSessionStatus.completed) {
                _showCompletionDialog(context, state);
              }
            },
            builder: (context, state) {
              if (state.session == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                children: [
                  // Header
                  _WorkoutSessionHeader(
                    workoutName: state.session!.workoutName,
                    formattedTime: state.formattedTime,
                    onBack: () async {
                      if (await _showExitConfirmation(context)) {
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    onFinish: () => _showFinishConfirmation(context),
                    onEditTime: () => _showTimeEditDialog(context, state),
                    onEditName: () => _showNameEditDialog(context, state),
                  ),

                  // Exercise list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md.w,
                        vertical: AppSpacing.sm.h,
                      ),
                      itemCount: state.session!.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = state.session!.exercises[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md.h),
                          child: _ActiveExerciseCard(
                            exercise: exercise,
                            exerciseIndex: index,
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom bar
                  _WorkoutSessionBottomBar(
                    onLogNextSet: () {
                      context.read<WorkoutSessionBloc>().add(LogNextSetEvent());
                    },
                    onToggleAll: () {
                      context.read<WorkoutSessionBloc>().add(
                        CompleteAllSetsEvent(),
                      );
                    },
                    allCompleted: state.session!.isCompleted,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        title: Text(
          'Thoát buổi tập?',
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeLg,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Tiến độ buổi tập sẽ không được lưu. Bạn có chắc muốn thoát?',
          style: AppTypography.bodyRegularStyle(
            fontSize: AppTypography.fontSizeBase,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Tiếp tục tập',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(
              'Thoát',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showFinishConfirmation(BuildContext context) {
    final bloc = context.read<WorkoutSessionBloc>();
    final currentState = bloc.state;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          title: Text(
            'Hoàn thành buổi tập?',
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeLg,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng kết:',
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeBase,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              _buildSummaryRow('Thời gian', currentState.formattedTime),
              _buildSummaryRow(
                'Sets hoàn thành',
                '${currentState.session?.totalCompletedSets ?? 0}/${currentState.session?.totalSets ?? 0}',
              ),
              _buildSummaryRow(
                'Bài tập hoàn thành',
                '${currentState.session?.completedExercisesCount ?? 0}/${currentState.session?.totalExercisesCount ?? 0}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Hủy',
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                bloc.add(FinishWorkoutEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(
                'Hoàn thành',
                style: AppTypography.bodyBoldStyle(
                  fontSize: AppTypography.fontSizeSm,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyBoldStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(BuildContext context, WorkoutSessionState state) {
    int suitability = 8;
    bool workoutGoalAchieved = true;
    bool targetMuscleFelt = true;
    final injuryController = TextEditingController();
    final additionalNotesController = TextEditingController();

    final bloc = context.read<WorkoutSessionBloc>();
    bloc.add(ResetFeedbackStatusEvent()); // Reset status before showing dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
          listener: (context, state) {
            if (state.feedbackStatus == FeedbackSubmissionStatus.success) {
              Navigator.of(dialogContext).pop(); // Close dialog
              Navigator.of(context).pop(true); // Close screen
            } else if (state.feedbackStatus ==
                FeedbackSubmissionStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Có lỗi xảy ra khi gửi đánh giá')),
              );
            }
          },
          builder: (context, state) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.celebration,
                        color: AppColors.primary,
                        size: 28.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Tuyệt vời!',
                        style: AppTypography.bodyBoldStyle(
                          fontSize: AppTypography.fontSizeLg,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bạn đã hoàn thành buổi tập!',
                            style: AppTypography.bodyRegularStyle(
                              fontSize: AppTypography.fontSizeBase,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: AppRadius.radiusMd,
                            ),
                            child: Column(
                              children: [
                                _buildCompletionStat(
                                  Icons.timer_outlined,
                                  'Thời gian',
                                  state.formattedTime,
                                ),
                                SizedBox(height: 8.h),
                                _buildCompletionStat(
                                  Icons.fitness_center,
                                  'Sets hoàn thành',
                                  '${state.session?.totalCompletedSets ?? 0}',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text(
                            'Đánh giá buổi tập (1-10)',
                            style: AppTypography.bodyBoldStyle(
                              fontSize: AppTypography.fontSizeBase,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(10, (index) {
                                final value = index + 1;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      suitability = value;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 8.w),
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: suitability == value
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: suitability == value
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$value',
                                      style: AppTypography.bodyBoldStyle(
                                        fontSize: AppTypography.fontSizeSm,
                                        color: suitability == value
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          SwitchListTile(
                            title: Text(
                              'Đạt mục tiêu?',
                              style: AppTypography.bodyRegularStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            value: workoutGoalAchieved,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => workoutGoalAchieved = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          SwitchListTile(
                            title: Text(
                              'Cảm nhận cơ bắp?',
                              style: AppTypography.bodyRegularStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            value: targetMuscleFelt,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => targetMuscleFelt = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          SizedBox(height: 8.h),
                          TextField(
                            controller: injuryController,
                            decoration: InputDecoration(
                              labelText: 'Ghi chú chấn thương/đau (nếu có)',
                              labelStyle: AppTypography.bodyRegularStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusSm,
                              ),
                              contentPadding: EdgeInsets.all(12.w),
                            ),
                            maxLines: 2,
                            style: AppTypography.bodyRegularStyle(
                              fontSize: AppTypography.fontSizeSm,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          TextField(
                            controller: additionalNotesController,
                            decoration: InputDecoration(
                              labelText: 'Ghi chú thêm',
                              labelStyle: AppTypography.bodyRegularStyle(
                                fontSize: AppTypography.fontSizeSm,
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusSm,
                              ),
                              contentPadding: EdgeInsets.all(12.w),
                            ),
                            maxLines: 2,
                            style: AppTypography.bodyRegularStyle(
                              fontSize: AppTypography.fontSizeSm,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed:
                          state.feedbackStatus ==
                              FeedbackSubmissionStatus.submitting
                          ? null
                          : () {
                              bloc.add(
                                CreateWorkoutFeedbackEvent(
                                  suitability: suitability,
                                  workoutGoalAchieved: workoutGoalAchieved,
                                  targetMuscleFelt: targetMuscleFelt,
                                  injuryOrPainNotes:
                                      injuryController.text.trim().isEmpty
                                      ? null
                                      : injuryController.text.trim(),
                                  additionalNotes:
                                      additionalNotesController.text
                                          .trim()
                                          .isEmpty
                                      ? null
                                      : additionalNotesController.text.trim(),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.radiusSm,
                        ),
                      ),
                      child:
                          state.feedbackStatus ==
                              FeedbackSubmissionStatus.submitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Gửi & Hoàn thành',
                              style: AppTypography.bodyBoldStyle(
                                fontSize: AppTypography.fontSizeBase,
                                color: AppColors.white,
                              ),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompletionStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyRegularStyle(
              fontSize: AppTypography.fontSizeSm,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeSm,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _showTimeEditDialog(BuildContext context, WorkoutSessionState state) {
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chỉnh sửa thời gian đang phát triển'),
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, WorkoutSessionState state) {
    final bloc = context.read<WorkoutSessionBloc>();
    final controller = TextEditingController(text: state.session?.workoutName);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        title: Text(
          'Đổi tên buổi tập',
          style: AppTypography.bodyBoldStyle(
            fontSize: AppTypography.fontSizeLg,
            color: AppColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tên buổi tập',
            border: OutlineInputBorder(borderRadius: AppRadius.radiusSm),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                bloc.add(UpdateWorkoutNameEvent(controller.text.trim()));
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              'Lưu',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeSm,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
