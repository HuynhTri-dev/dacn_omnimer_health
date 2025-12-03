import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_state.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/calories_burned_chart.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/weight_progress_chart.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/muscle_distribution_chart.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/widgets/goal_progress_chart.dart';

class ChartsSection extends StatelessWidget {
  final ReportState state;

  const ChartsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (state.isChartLoading) {
      return Container(
        padding: EdgeInsets.all(32.w),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.h),

        // Calories Burned Chart - now handles empty data internally
        CaloriesBurnedChart(data: state.caloriesBurned),

        SizedBox(height: 16.h),

        // Weight Progress Chart (needs at least 2 data points for line chart)
        if (state.weightProgress.length >= 2)
          WeightProgressChart(data: state.weightProgress)
        else
          const EmptyChartPlaceholder(title: 'Weight Progress'),

        SizedBox(height: 16.h),

        // Two charts in a row
        Row(
          children: [
            // Muscle Distribution Chart - now handles empty data internally
            Expanded(
              child: MuscleDistributionChart(data: state.muscleDistribution),
            ),
            SizedBox(width: 12.w),
            // Goal Progress Chart (needs at least one non-zero count)
            Expanded(
              child:
                  state.goalProgress.isNotEmpty &&
                      state.goalProgress.any((g) => g.count > 0)
                  ? GoalProgressChart(data: state.goalProgress)
                  : const EmptyChartPlaceholder(title: 'Goal Progress'),
            ),
          ],
        ),
      ],
    );
  }
}

class EmptyChartPlaceholder extends StatelessWidget {
  final String title;

  const EmptyChartPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Icon(
            Icons.show_chart,
            size: 48.sp,
            color: Colors.grey.withOpacity(0.5),
          ),
          SizedBox(height: 8.h),
          Text(
            'No data available',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
