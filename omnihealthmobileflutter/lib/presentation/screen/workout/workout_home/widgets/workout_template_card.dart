part of '../workout_home_screen.dart';

class _WorkoutTemplateCard extends StatelessWidget {
  final WorkoutTemplateEntity template;
  final VoidCallback onTap;

  const _WorkoutTemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Combine exercise types names
    final typesText = template.exerciseTypes.isNotEmpty
        ? template.exerciseTypes.map((type) => type.name).join(', ')
        : 'N/A';

    // Combine body parts names
    final bodyPartsText = template.bodyPartsTarget.isNotEmpty
        ? template.bodyPartsTarget.map((part) => part.name).join(', ')
        : 'N/A';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: template.createdByAI
                        ? Colors.purple.withOpacity(0.1)
                        : Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    template.createdByAI
                        ? Icons.psychology_outlined
                        : Icons.fitness_center_outlined,
                    color: template.createdByAI
                        ? Colors.purple
                        : Theme.of(context).primaryColor,
                    size: 24.sp,
                  ),
                ),
                
                SizedBox(width: 12.w),
                
                // Template info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template name
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 4.h),
                      
                      // Description
                      if (template.description.isNotEmpty)
                        Text(
                          template.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                
                SizedBox(width: 8.w),
                
                // Location badge
                if (template.location != null && template.location!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      template.location!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Exercise types
            _InfoRow(
              label: 'Type:',
              value: typesText,
              maxLines: 1,
            ),
            
            SizedBox(height: 4.h),
            
            // Body parts
            _InfoRow(
              label: 'Body Part:',
              value: bodyPartsText,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _InfoRow({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

