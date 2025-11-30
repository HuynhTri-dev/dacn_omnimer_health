import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_radius.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/core/theme/app_typography.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_event.dart';
import 'package:omnihealthmobileflutter/presentation/screen/workout/workout_session/bloc/workout_session_state.dart';

class WorkoutCompletionDialog extends StatefulWidget {
  final WorkoutSessionBloc bloc;
  final WorkoutSessionState state;

  const WorkoutCompletionDialog({
    super.key,
    required this.bloc,
    required this.state,
  });

  @override
  State<WorkoutCompletionDialog> createState() =>
      _WorkoutCompletionDialogState();
}

class _WorkoutCompletionDialogState extends State<WorkoutCompletionDialog> {
  int suitability = 8;
  bool workoutGoalAchieved = true;
  bool targetMuscleFelt = true;
  final injuryController = TextEditingController();
  final additionalNotesController = TextEditingController();

  @override
  void dispose() {
    injuryController.dispose();
    additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: BlocConsumer<WorkoutSessionBloc, WorkoutSessionState>(
        listener: (context, state) {
          if (state.feedbackStatus == FeedbackSubmissionStatus.success) {
            // Schedule navigation after current frame to avoid bloc errors
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Close screen
              }
            });
          } else if (state.feedbackStatus == FeedbackSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Có lỗi xảy ra khi gửi đánh giá')),
            );
          }
        },
        builder: (context, state) {
          return AlertDialog(
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
                            widget.state.formattedTime,
                          ),
                          SizedBox(height: 8.h),
                          _buildCompletionStat(
                            Icons.fitness_center,
                            'Sets hoàn thành',
                            '${widget.state.session?.totalCompletedSets ?? 0}',
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
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(true); // Close screen
                },
                child: Text(
                  'Bỏ qua',
                  style: AppTypography.bodyBoldStyle(
                    fontSize: AppTypography.fontSizeBase,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    state.feedbackStatus == FeedbackSubmissionStatus.submitting
                    ? null
                    : () {
                        widget.bloc.add(
                          CreateWorkoutFeedbackEvent(
                            suitability: suitability,
                            workoutGoalAchieved: workoutGoalAchieved,
                            targetMuscleFelt: targetMuscleFelt,
                            injuryOrPainNotes:
                                injuryController.text.trim().isEmpty
                                ? null
                                : injuryController.text.trim(),
                            additionalNotes:
                                additionalNotesController.text.trim().isEmpty
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
                    state.feedbackStatus == FeedbackSubmissionStatus.submitting
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
            fontSize: AppTypography.fontSizeBase,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
