part of '../workout_home_screen.dart';

class _WeeklyWorkoutChart extends StatelessWidget {
  final WorkoutStatsEntity stats;

  const _WeeklyWorkoutChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final maxHours = stats.weeklyStats
        .map((stat) => stat.hours)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Workout Hours Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 16.h),
          
          // Bar Chart
          SizedBox(
            height: 180.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.weeklyStats.map((dayStat) {
                final heightRatio = maxHours > 0 ? dayStat.hours / maxHours : 0;
                final barHeight = 120.h * heightRatio;
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Hours label
                        if (dayStat.hours > 0)
                          Padding(
                            padding: EdgeInsets.only(bottom: 4.h),
                            child: Text(
                              dayStat.hours.toInt().toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                            ),
                          )
                        else
                          SizedBox(height: 14.h),
                        
                        // Bar
                        Container(
                          width: double.infinity,
                          height: barHeight.clamp(20.h, 120.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        // Day label
                        Text(
                          dayStat.dayOfWeek,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10.sp,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

