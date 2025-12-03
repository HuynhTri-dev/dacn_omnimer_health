import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/goal_progress_entity.dart';

class GoalProgressChart extends StatelessWidget {
  final List<GoalProgressEntity> data;

  const GoalProgressChart({super.key, required this.data});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF22C55E); // Green
      case 'in_progress':
      case 'in progress':
        return const Color(0xFF3B82F6); // Blue
      case 'not_started':
      case 'not started':
        return const Color(0xFF9CA3AF); // Gray
      case 'cancelled':
      case 'failed':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out zero count items for pie chart
    final filteredData = data.where((item) => item.count > 0).toList();
    final totalCount = filteredData.fold<int>(
      0,
      (sum, item) => sum + item.count,
    );

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Goal Progress',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 25.r,
                sections: filteredData.map((item) {
                  final percentage = totalCount > 0
                      ? (item.count / totalCount * 100)
                      : 0.0;

                  return PieChartSectionData(
                    color: _getStatusColor(item.status),
                    value: item.count.toDouble(),
                    title: '${percentage.toStringAsFixed(0)}%',
                    radius: 35.r,
                    titleStyle: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Legend
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: filteredData.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _getStatusColor(item.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatStatus(item.status),
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.grey,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
