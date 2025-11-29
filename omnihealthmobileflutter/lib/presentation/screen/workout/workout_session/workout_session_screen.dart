import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/active_workout_session_entity.dart';
import 'package:omnihealthmobileflutter/domain/entities/workout/workout_template_entity.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/cubits/workout_session_cubit.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/cubits/workout_session_state.dart';

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
    context.read<WorkoutSessionCubit>().startWorkout(widget.template);
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
          child: BlocConsumer<WorkoutSessionCubit, WorkoutSessionState>(
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
                      context.read<WorkoutSessionCubit>().logNextSet();
                    },
                    onToggleAll: () {
                      context.read<WorkoutSessionCubit>().completeAllSets();
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
    final cubit = context.read<WorkoutSessionCubit>();
    final currentState = cubit.state;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
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
                cubit.finishWorkout();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary, size: 28.sp),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 8.h),
                  _buildCompletionStat(
                    Icons.check_circle_outline,
                    'Bài tập',
                    '${state.session?.completedExercisesCount ?? 0}/${state.session?.totalExercisesCount ?? 0}',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(
              'Xong',
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeBase,
                color: AppColors.white,
              ),
            ),
          ),
        ],
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
    final cubit = context.read<WorkoutSessionCubit>();
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
                cubit.updateWorkoutName(controller.text.trim());
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
