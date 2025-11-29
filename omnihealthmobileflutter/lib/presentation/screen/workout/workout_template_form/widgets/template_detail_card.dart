part of '../workout_template_form_screen.dart';

class _TemplateDetailCard extends StatelessWidget {
  final VoidCallback onAddDetail;
  final VoidCallback onAddExercises;

  const _TemplateDetailCard({
    required this.onAddDetail,
    required this.onAddExercises,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Template Info',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          SizedBox(height: 16.h),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.tune,
                  label: 'Add Details',
                  onPressed: onAddDetail,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ActionButton(
                  icon: Icons.fitness_center,
                  label: 'Add Exercise',
                  onPressed: onAddExercises,
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(
          label,
          style: TextStyle(fontSize: 13.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          elevation: 0,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 13.sp),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        side: BorderSide(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      ),
    );
  }
}

