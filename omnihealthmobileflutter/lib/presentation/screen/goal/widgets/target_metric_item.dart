import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/core/theme/app_spacing.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';
import 'package:omnihealthmobileflutter/presentation/common/input_fields/custom_text_field.dart';

class TargetMetricItem extends StatelessWidget {
  final int index;
  final TargetMetricEntity metric;
  final Function(int index, {String? name, double? value, String? unit})
  onUpdate;
  final VoidCallback onRemove;

  const TargetMetricItem({
    super.key,
    required this.index,
    required this.metric,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      padding: EdgeInsets.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Metric Name',
                  value: metric.metricName,
                  onChanged: (val) => onUpdate(index, name: val),
                  placeholder: 'e.g. Weight',
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Value',
                  value: metric.value == 0 ? '' : metric.value.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (val) =>
                      onUpdate(index, value: double.tryParse(val) ?? 0),
                  placeholder: '0.0',
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: CustomTextField(
                  label: 'Unit',
                  value: metric.unit,
                  onChanged: (val) => onUpdate(index, unit: val),
                  placeholder: 'e.g. kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
