part of '../workout_template_form_screen.dart';

class _SetRow extends StatelessWidget {
  final WorkoutSetFormData set;
  final int exerciseIndex;
  final int setIndex;

  const _SetRow({
    required this.set,
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Set number
        Container(
          width: 40.w,
          alignment: Alignment.center,
          child: Text(
            '${set.setOrder}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Weight input
        Expanded(
          child: _InputField(
            value: set.weight?.toString() ?? '',
            hintText: '-',
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
        
        // Reps input
        Expanded(
          child: _InputField(
            value: set.reps?.toString() ?? '',
            hintText: '-',
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
        
        // More menu
        SizedBox(
          width: 40.w,
          child: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20.sp),
            onSelected: (value) {
              if (value == 'delete') {
                context
                    .read<WorkoutTemplateFormCubit>()
                    .removeSet(exerciseIndex, setIndex);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String value;
  final String hintText;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.value,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: TextField(
        controller: TextEditingController(text: value)
          ..selection = TextSelection.collapsed(offset: value.length),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

