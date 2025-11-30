part of '../workout_template_form_screen.dart';

class _SetRow extends StatelessWidget {
  final WorkoutSetFormData set;
  final int exerciseIndex;
  final int setIndex;
  final String exerciseType;

  const _SetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
    required this.exerciseType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Set number badge
        Container(
          width: 36.w,
          height: 36.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${set.setOrder}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // Dynamic fields based on exercise type
        ..._buildInputFields(context),

        // Type & Delete menu
        SizedBox(
          width: 32.w,
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18.sp, color: Colors.grey[600]),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'delete') {
                context.read<WorkoutTemplateFormCubit>().removeSet(
                  exerciseIndex,
                  setIndex,
                );
              } else if (value.startsWith('type_')) {
                final newType = value.replaceFirst('type_', '');
                context.read<WorkoutTemplateFormCubit>().updateExerciseType(
                  exerciseIndex,
                  newType,
                );
              }
            },
            itemBuilder: (ctx) => [
              // Type header
              PopupMenuItem(
                enabled: false,
                height: 28,
                child: Text(
                  'Exercise Type',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              _buildTypeMenuItem(ctx, 'reps', 'Reps & Weight', Icons.fitness_center),
              _buildTypeMenuItem(ctx, 'time', 'Time Based', Icons.timer),
              _buildTypeMenuItem(ctx, 'distance', 'Distance', Icons.directions_run),
              _buildTypeMenuItem(ctx, 'mixed', 'Mixed', Icons.tune),
              const PopupMenuDivider(),
              // Delete
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Set', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildTypeMenuItem(
    BuildContext context,
    String type,
    String label,
    IconData icon,
  ) {
    final isSelected = exerciseType == type;
    return PopupMenuItem(
      value: 'type_$type',
      height: 40,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Theme.of(context).primaryColor : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor),
        ],
      ),
    );
  }

  List<Widget> _buildInputFields(BuildContext context) {
    switch (exerciseType) {
      case 'reps':
        return [
          // Weight
          Expanded(
            child: _InputField(
              key: ValueKey('weight_${exerciseIndex}_$setIndex'),
              initialValue: set.weight?.toString() ?? '',
              hintText: '0',
              suffix: 'kg',
              onChanged: (value) {
                final weight = double.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  weight: weight,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          // Reps
          Expanded(
            child: _InputField(
              key: ValueKey('reps_${exerciseIndex}_$setIndex'),
              initialValue: set.reps?.toString() ?? '',
              hintText: '0',
              suffix: 'x',
              onChanged: (value) {
                final reps = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  reps: reps,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          // Rest
          Expanded(
            child: _InputField(
              key: ValueKey('rest_${exerciseIndex}_$setIndex'),
              initialValue: set.restAfterSetSeconds?.toString() ?? '',
              hintText: '0',
              suffix: 's',
              onChanged: (value) {
                final rest = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  restAfterSetSeconds: rest,
                );
              },
            ),
          ),
        ];

      case 'time':
        return [
          // Reps
          Expanded(
            child: _InputField(
              key: ValueKey('reps_${exerciseIndex}_$setIndex'),
              initialValue: set.reps?.toString() ?? '',
              hintText: '0',
              suffix: 'x',
              onChanged: (value) {
                final reps = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  reps: reps,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          // Duration
          Expanded(
            child: _InputField(
              key: ValueKey('duration_${exerciseIndex}_$setIndex'),
              initialValue: set.duration?.toString() ?? '',
              hintText: '0',
              suffix: 'sec',
              onChanged: (value) {
                final duration = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  duration: duration,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          // Rest
          Expanded(
            child: _InputField(
              key: ValueKey('rest_${exerciseIndex}_$setIndex'),
              initialValue: set.restAfterSetSeconds?.toString() ?? '',
              hintText: '0',
              suffix: 's',
              onChanged: (value) {
                final rest = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  restAfterSetSeconds: rest,
                );
              },
            ),
          ),
        ];

      case 'distance':
        return [
          // Distance
          Expanded(
            flex: 2,
            child: _InputField(
              key: ValueKey('distance_${exerciseIndex}_$setIndex'),
              initialValue: set.distance?.toString() ?? '',
              hintText: '0',
              suffix: 'm',
              onChanged: (value) {
                final distance = double.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  distance: distance,
                );
              },
            ),
          ),
        ];

      case 'mixed':
        // Mixed type uses a special expanded layout
        return [
          Expanded(
            child: _MixedFieldsGrid(
              set: set,
              exerciseIndex: exerciseIndex,
              setIndex: setIndex,
            ),
          ),
        ];

      default:
        return [
          // Weight
          Expanded(
            child: _InputField(
              key: ValueKey('weight_${exerciseIndex}_$setIndex'),
              initialValue: set.weight?.toString() ?? '',
              hintText: '0',
              suffix: 'kg',
              onChanged: (value) {
                final weight = double.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  weight: weight,
                );
              },
            ),
          ),
          SizedBox(width: 6.w),
          // Reps
          Expanded(
            child: _InputField(
              key: ValueKey('reps_${exerciseIndex}_$setIndex'),
              initialValue: set.reps?.toString() ?? '',
              hintText: '0',
              suffix: 'x',
              onChanged: (value) {
                final reps = int.tryParse(value);
                context.read<WorkoutTemplateFormCubit>().updateSet(
                  exerciseIndex,
                  setIndex,
                  reps: reps,
                );
              },
            ),
          ),
        ];
    }
  }
}

class _InputField extends StatefulWidget {
  final String initialValue;
  final String hintText;
  final String? suffix;
  final ValueChanged<String> onChanged;

  const _InputField({
    super.key,
    required this.initialValue,
    required this.hintText,
    this.suffix,
    required this.onChanged,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 10.h,
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (widget.suffix != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(9.r),
                  bottomRight: Radius.circular(9.r),
                ),
              ),
              height: double.infinity,
              alignment: Alignment.center,
              child: Text(
                widget.suffix!,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mixed type fields grid - 2 rows layout
class _MixedFieldsGrid extends StatelessWidget {
  final WorkoutSetFormData set;
  final int exerciseIndex;
  final int setIndex;

  const _MixedFieldsGrid({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Weight, Reps, Duration
        Row(
          children: [
            Expanded(
              child: _LabeledInput(
                key: ValueKey('mixed_weight_${exerciseIndex}_$setIndex'),
                label: 'Weight',
                suffix: 'kg',
                initialValue: set.weight?.toString() ?? '',
                onChanged: (value) {
                  final weight = double.tryParse(value);
                  context.read<WorkoutTemplateFormCubit>().updateSet(
                    exerciseIndex,
                    setIndex,
                    weight: weight,
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _LabeledInput(
                key: ValueKey('mixed_reps_${exerciseIndex}_$setIndex'),
                label: 'Reps',
                suffix: 'x',
                initialValue: set.reps?.toString() ?? '',
                onChanged: (value) {
                  final reps = int.tryParse(value);
                  context.read<WorkoutTemplateFormCubit>().updateSet(
                    exerciseIndex,
                    setIndex,
                    reps: reps,
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _LabeledInput(
                key: ValueKey('mixed_duration_${exerciseIndex}_$setIndex'),
                label: 'Duration',
                suffix: 's',
                initialValue: set.duration?.toString() ?? '',
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  context.read<WorkoutTemplateFormCubit>().updateSet(
                    exerciseIndex,
                    setIndex,
                    duration: duration,
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        // Row 2: Distance, Rest
        Row(
          children: [
            Expanded(
              child: _LabeledInput(
                key: ValueKey('mixed_distance_${exerciseIndex}_$setIndex'),
                label: 'Distance',
                suffix: 'm',
                initialValue: set.distance?.toString() ?? '',
                onChanged: (value) {
                  final distance = double.tryParse(value);
                  context.read<WorkoutTemplateFormCubit>().updateSet(
                    exerciseIndex,
                    setIndex,
                    distance: distance,
                  );
                },
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _LabeledInput(
                key: ValueKey('mixed_rest_${exerciseIndex}_$setIndex'),
                label: 'Rest',
                suffix: 's',
                initialValue: set.restAfterSetSeconds?.toString() ?? '',
                onChanged: (value) {
                  final rest = int.tryParse(value);
                  context.read<WorkoutTemplateFormCubit>().updateSet(
                    exerciseIndex,
                    setIndex,
                    restAfterSetSeconds: rest,
                  );
                },
              ),
            ),
            // Empty space to balance with row 1
            Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

/// Labeled input field for mixed type
class _LabeledInput extends StatefulWidget {
  final String label;
  final String suffix;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _LabeledInput({
    super.key,
    required this.label,
    required this.suffix,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<_LabeledInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _LabeledInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: 4.h),
        // Input
        Container(
          height: 36.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(7.r),
                    bottomRight: Radius.circular(7.r),
                  ),
                ),
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  widget.suffix,
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
