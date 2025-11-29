// lib/presentation/screen/exercise/exercise_home/widgets/header_and_search.dart
part of '../exercise_home_screen.dart';

class _BodyAndMuscleHeader extends StatelessWidget {
  final MuscleEntity? selectedMuscle;

  const _BodyAndMuscleHeader({required this.selectedMuscle});

  @override
  Widget build(BuildContext context) {
    final muscle = selectedMuscle;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ======= MODEL 3D BÊN TRÁI =======
        Expanded(
          flex: 3,
          child: Container(
            height: 220.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.radiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: AppRadius.radiusXl,
              child: Cube(
                onSceneCreated: (Scene scene) {
                  final object = Object(fileName: 'assets/models/mesh.obj');

                  object.scale.setValues(0.32, 0.32, 0.32);

                  scene.world.add(object);

                  scene.camera.zoom = 20;
                  scene.camera.position.setValues(30, 2, 0);
                },
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // ======= CARD MUSCLE BÊN PHẢI =======
        Expanded(
          flex: 2,
          child: Container(
            height: 220.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: AppRadius.radiusXl,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  muscle?.name ?? 'Muscle Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                Text(
                  muscle?.description ?? 'Description...',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: AppRadius.radiusLg,
                  child: (muscle?.imageUrl?.isNotEmpty == true)
                      ? Image.network(
                          muscle!.imageUrl!,
                          height: 90.h,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 90.h,
                          width: double.infinity,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          alignment: Alignment.center,
                          child: const Icon(Icons.image),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int resultCount;
  final VoidCallback onPressed;

  const _FilterButton({required this.resultCount, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 20, color: AppColors.primary),
            SizedBox(height: 4.h),
            Text(
              '$resultCount',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm bài tập...',
        hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide:
              Theme.of(context).inputDecorationTheme.border?.borderSide ??
              BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide:
              Theme.of(
                context,
              ).inputDecorationTheme.enabledBorder?.borderSide ??
              BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide:
              Theme.of(
                context,
              ).inputDecorationTheme.focusedBorder?.borderSide ??
              BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
