part of '../workout_template_detail_screen.dart';

class _TemplateInfoSection extends StatelessWidget {
  final WorkoutTemplateEntity template;

  const _TemplateInfoSection({required this.template});

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
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),

          // Body Parts
          if (template.bodyPartsTarget.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.accessibility_new,
              label: 'Target Body Parts',
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.bodyPartsTarget.map((part) {
                  return _Chip(label: part.name, color: Colors.blue);
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Exercise Types
          if (template.exerciseTypes.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.category,
              label: 'Exercise Types',
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.exerciseTypes.map((type) {
                  return _Chip(label: type.name, color: Colors.green);
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Exercise Categories
          if (template.exerciseCategories.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.label,
              label: 'Categories',
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.exerciseCategories.map((cat) {
                  return _Chip(label: cat.name, color: Colors.orange);
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Equipments
          if (template.equipments.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.sports_gymnastics,
              label: 'Equipment',
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.equipments.map((equip) {
                  return _Chip(label: equip.name, color: Colors.purple);
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Muscles Target
          if (template.musclesTarget.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.fitness_center,
              label: 'Target Muscles',
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: template.musclesTarget.map((muscle) {
                  return _Chip(label: muscle.name, color: Colors.red);
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Notes
          if (template.notes != null && template.notes!.isNotEmpty) ...[
            _InfoItem(
              icon: Icons.notes,
              label: 'Notes',
              child: Text(
                template.notes!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ),
          ],

          // Created At
          if (template.createdAt != null) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14.sp,
                  color: Colors.grey[500],
                ),
                SizedBox(width: 6.w),
                Text(
                  'Created: ${_formatDate(template.createdAt!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

