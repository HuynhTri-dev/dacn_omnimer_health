import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/domain/entities/chart/muscle_distribution_entity.dart';

class MuscleDistributionChart extends StatelessWidget {
  final List<MuscleDistributionEntity> data;

  const MuscleDistributionChart({super.key, required this.data});

  static const List<Color> _chartColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF22C55E), // Green
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter out zero counts, sort by count and take top 5
    // If data is empty, use dummy data for skeleton
    List<MuscleDistributionEntity> processedData;
    if (data.isEmpty) {
      processedData = [
        const MuscleDistributionEntity(muscleName: 'Chest', count: 0),
        const MuscleDistributionEntity(muscleName: 'Back', count: 0),
        const MuscleDistributionEntity(muscleName: 'Legs', count: 0),
        const MuscleDistributionEntity(muscleName: 'Arms', count: 0),
        const MuscleDistributionEntity(muscleName: 'Abs', count: 0),
      ];
    } else {
      processedData = data.where((item) => item.count > 0).toList()
        ..sort((a, b) => b.count.compareTo(a.count));
    }
    final displayData = processedData.take(5).toList();
    final totalCount = displayData.fold<int>(
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
            'Muscle Groups',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            child: totalCount > 0
                ? PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 25.r,
                      sections: displayData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final percentage = (item.count / totalCount * 100);

                        return PieChartSectionData(
                          color: _chartColors[index % _chartColors.length],
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
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 40.sp,
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Start working out\nto see muscle data',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.withOpacity(0.6),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          SizedBox(height: 8.h),
          // Legend - only show if there's data
          if (totalCount > 0)
            Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: displayData.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _chartColors[index % _chartColors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      item.muscleName,
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
