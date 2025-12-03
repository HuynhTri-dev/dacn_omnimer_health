import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyWorkoutHistory extends StatelessWidget {
  const EmptyWorkoutHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            Icon(Icons.history, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No workout history yet',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              'Complete your first workout to see it here',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
