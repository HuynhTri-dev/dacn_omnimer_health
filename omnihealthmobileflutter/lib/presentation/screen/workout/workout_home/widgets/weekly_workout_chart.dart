part of '../workout_home_screen.dart';

class _WeeklyWorkoutChart extends StatelessWidget {
  final List<WorkoutFrequencyEntity> frequencyData;

  const _WeeklyWorkoutChart({required this.frequencyData});

  // Helper function to get week number from date
  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  // Generate last 7 weeks with data
  List<WorkoutFrequencyEntity> _generateLast7Weeks() {
    final now = DateTime.now();
    final last7Weeks = <WorkoutFrequencyEntity>[];

    for (int i = 6; i >= 0; i--) {
      final weekDate = now.subtract(Duration(days: i * 7));
      final year = weekDate.year;
      final weekNumber = _getWeekNumber(weekDate);
      final period = '$year-W$weekNumber';

      // Find existing data for this week
      final existingData = frequencyData.firstWhere(
        (data) => data.period == period,
        orElse: () => WorkoutFrequencyEntity(period: period, count: 0),
      );

      last7Weeks.add(existingData);
    }

    return last7Weeks;
  }

  @override
  Widget build(BuildContext context) {
    // Generate last 7 weeks with filled data
    final displayData = _generateLast7Weeks();

    // Calculate max count, default to 1 to avoid division by zero
    final maxCount = displayData
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1, double.infinity)
        .toInt();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Workout Frequency',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Last 7 Weeks',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Bar Chart
          SizedBox(
            height: 160.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: displayData.map((data) {
                // Calculate bar height with minimum height for 0 values
                final heightRatio = data.count / maxCount;
                final calculatedHeight = 100.h * heightRatio;
                final minHeight = 12.h; // Minimum visible height
                final barHeight = data.count == 0
                    ? minHeight
                    : calculatedHeight.clamp(minHeight, 100.h);

                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Count label - always show
                        SizedBox(
                          height: 20.h,
                          child: data.count > 0
                              ? Text(
                                  data.count.toString(),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.sp,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  '0',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                        ),

                        SizedBox(height: 4.h),

                        // Bar
                        Container(
                          width: double.infinity,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: data.count == 0
                                ? Colors.grey.withOpacity(0.2)
                                : Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.8),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(6.r),
                            ),
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Period label (e.g., "W40")
                        Text(
                          data.period.contains('-W')
                              ? 'W${data.period.split('-W').last}'
                              : data.period.length > 6
                              ? data.period.substring(0, 6)
                              : data.period,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 9.sp,
                                color: Colors.grey[600],
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
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
