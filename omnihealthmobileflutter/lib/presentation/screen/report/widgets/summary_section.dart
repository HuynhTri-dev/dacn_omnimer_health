import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/presentation/screen/report/blocs/report_state.dart';

class SummarySection extends StatelessWidget {
  final ReportState state;

  const SummarySection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final summaryItems = [
      _SummaryItemData(
        Icons.fitness_center_rounded,
        'Workouts',
        state.totalWorkouts.toString(),
        const Color(0xFF5EAFD8),
        const Color(0xFF338BAB),
      ),
      _SummaryItemData(
        Icons.timer_outlined,
        'Total Time',
        state.formattedTotalDuration,
        const Color(0xFF34C759),
        const Color(0xFF28A745),
      ),
      _SummaryItemData(
        Icons.local_fire_department_rounded,
        'Calories',
        state.totalCalories.toStringAsFixed(0),
        const Color(0xFFFFCC00),
        const Color(0xFFFF9500),
      ),
      _SummaryItemData(
        Icons.favorite_rounded,
        'Heart Rate',
        '${state.avgHeartRate.toStringAsFixed(0)} - ${state.maxHeartRate.toStringAsFixed(0)}',
        const Color(0xFFFF3B30),
        const Color(0xFFE15858),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 4 columns if width is sufficient (e.g., tablet/landscape), else 2
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 2.5,
          ),
          itemCount: summaryItems.length,
          itemBuilder: (context, index) {
            final item = summaryItems[index];
            return SummaryCard(
              icon: item.icon,
              title: item.title,
              value: item.value,
              primaryColor: item.primaryColor,
              secondaryColor: item.secondaryColor,
            );
          },
        );
      },
    );
  }
}

class _SummaryItemData {
  final IconData icon;
  final String title;
  final String value;
  final Color primaryColor;
  final Color secondaryColor;

  _SummaryItemData(
    this.icon,
    this.title,
    this.value,
    this.primaryColor,
    this.secondaryColor,
  );
}

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color primaryColor;
  final Color secondaryColor;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: Colors.white, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
