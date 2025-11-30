part of '../workout_session_screen.dart';

class _ActiveSetRow extends StatefulWidget {
  final ActiveSetEntity set;
  final int exerciseIndex;
  final int setIndex;
  final bool isCurrentSet;

  const _ActiveSetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
    this.isCurrentSet = false,
  });

  @override
  State<_ActiveSetRow> createState() => _ActiveSetRowState();
}

class _ActiveSetRowState extends State<_ActiveSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.actualWeight?.toStringAsFixed(0) ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.actualReps?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(_ActiveSetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set.actualWeight != widget.set.actualWeight) {
      _weightController.text =
          widget.set.actualWeight?.toStringAsFixed(0) ?? '';
    }
    if (oldWidget.set.actualReps != widget.set.actualReps) {
      _repsController.text = widget.set.actualReps?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.set.isCompleted;
    final isCurrentSet = widget.isCurrentSet;

    return Row(
      children: [
        // Current set indicator arrow
        SizedBox(
          width: 16.w,
          child: isCurrentSet
              ? Icon(Icons.play_arrow, size: 16.sp, color: AppColors.success)
              : null,
        ),

        // Set row content
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: AppSpacing.xs.w,
              vertical: AppSpacing.xs.h,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md.w,
              vertical: AppSpacing.sm.h,
            ),
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.success : AppColors.gray100,
              borderRadius: AppRadius.radiusMd,
              border: isCurrentSet && !isCompleted
                  ? Border.all(color: AppColors.success, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                // Checkbox
                _buildCheckbox(context, isCompleted),
                SizedBox(width: AppSpacing.md.w),

                // Set number
                SizedBox(
                  width: 24.w,
                  child: Text(
                    '${widget.set.setOrder}',
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeBase,
                      color: isCompleted
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: AppSpacing.md.w),

                // Weight input with KG label
                _buildInputWithLabel(
                  context,
                  controller: _weightController,
                  label: 'KG',
                  isCompleted: isCompleted,
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null) {
                      context.read<WorkoutSessionBloc>().add(
                        UpdateSetWeightEvent(
                          widget.exerciseIndex,
                          widget.setIndex,
                          weight,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(width: AppSpacing.md.w),

                // Reps input with REPS label
                _buildInputWithLabel(
                  context,
                  controller: _repsController,
                  label: 'REPS',
                  isCompleted: isCompleted,
                  onChanged: (value) {
                    final reps = int.tryParse(value);
                    if (reps != null) {
                      context.read<WorkoutSessionBloc>().add(
                        UpdateSetRepsEvent(
                          widget.exerciseIndex,
                          widget.setIndex,
                          reps,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(BuildContext context, bool isCompleted) {
    return GestureDetector(
      onTap: () {
        context.read<WorkoutSessionBloc>().add(
          ToggleSetCompletionEvent(widget.exerciseIndex, widget.setIndex),
        );
      },
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isCompleted ? AppColors.success : AppColors.gray300,
            width: 2,
          ),
        ),
        child: isCompleted
            ? Icon(Icons.check, size: 16.sp, color: AppColors.success)
            : null,
      ),
    );
  }

  Widget _buildInputWithLabel(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool isCompleted,
    required ValueChanged<String> onChanged,
  }) {
    return Expanded(
      child: Row(
        children: [
          // Input field - show as text when completed, editable when not
          Container(
            width: 48.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.white.withOpacity(0.25)
                  : AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isCompleted
                    ? AppColors.white.withOpacity(0.4)
                    : AppColors.gray300,
              ),
            ),
            alignment: Alignment.center,
            child: isCompleted
                ? Text(
                    controller.text,
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                : TextField(
                    controller: controller,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: AppTypography.bodyBoldStyle(
                      fontSize: AppTypography.fontSizeSm,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      isCollapsed: true,
                    ),
                    onChanged: onChanged,
                  ),
          ),
          SizedBox(width: 6.w),
          // Label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.white.withOpacity(0.25)
                  : AppColors.gray200,
              borderRadius: BorderRadius.circular(8.r),
              border: isCompleted
                  ? Border.all(color: AppColors.white.withOpacity(0.4))
                  : null,
            ),
            child: Text(
              label,
              style: AppTypography.bodyBoldStyle(
                fontSize: AppTypography.fontSizeXs,
                color: isCompleted ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
