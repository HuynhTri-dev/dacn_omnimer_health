part of '../workout_template_detail_screen.dart';

class _TemplateDetailHeader extends StatelessWidget {
  final WorkoutTemplateEntity template;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TemplateDetailHeader({
    required this.template,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  String _getLocationLabel(String location) {
    switch (location.toLowerCase()) {
      case 'gym':
        return 'Gym';
      case 'home':
        return 'Home';
      case 'outdoor':
        return 'Outdoor';
      default:
        return location;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with back button and action buttons
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // AI Badge
                    if (template.createdByAI)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.psychology,
                              color: Colors.purple,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.purple,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).primaryColor,
                  size: 22.sp,
                ),
              ),
              IconButton(
                onPressed: () => _showDeleteConfirmation(context),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[400],
                  size: 22.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Template name and info card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Template name
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (template.description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    template.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                SizedBox(height: 12.h),

                // Quick stats row
                Row(
                  children: [
                    _QuickStat(
                      icon: Icons.fitness_center,
                      value: '${template.workOutDetail.length}',
                      label: 'Exercises',
                    ),
                    SizedBox(width: 20.w),
                    if (template.location != null && template.location!.isNotEmpty)
                      _QuickStat(
                        icon: Icons.location_on,
                        value: _getLocationLabel(template.location!),
                        label: 'Location',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Workout Template'),
        content: Text(
          'Are you sure you want to delete "${template.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

