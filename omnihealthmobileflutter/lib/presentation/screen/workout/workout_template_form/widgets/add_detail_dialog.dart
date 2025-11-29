part of '../workout_template_form_screen.dart';

class _AddDetailDialog extends StatefulWidget {
  const _AddDetailDialog();

  @override
  State<_AddDetailDialog> createState() => _AddDetailDialogState();
}

class _AddDetailDialogState extends State<_AddDetailDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  String? _selectedLocation;

  final List<String> _locations = ['gym', 'home', 'outdoor', 'none'];

  @override
  void initState() {
    super.initState();
    final state = context.read<WorkoutTemplateFormCubit>().state;
    _descriptionController = TextEditingController(text: state.description);
    _notesController = TextEditingController(text: state.notes ?? '');
    _selectedLocation = state.location;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getLocationLabel(String location) {
    switch (location) {
      case 'gym':
        return 'Gym';
      case 'home':
        return 'Home';
      case 'outdoor':
        return 'Outdoor';
      case 'none':
        return 'Not specified';
      default:
        return location.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Template Details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Text(
              'Description',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter template description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 16.h),
            
            // Notes
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Enter notes',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 3,
            ),
            
            SizedBox(height: 16.h),
            
            // Location
            Text(
              'Location',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              hint: const Text('Select location'),
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(_getLocationLabel(location)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value;
                });
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Equipment, Body Parts, etc. (Multi-select chips)
            Text(
              'Additional Info',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Equipment, body parts, and exercise types will be automatically added from your selected exercises.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<WorkoutTemplateFormCubit>().updateDetails(
                  description: _descriptionController.text.trim(),
                  notes: _notesController.text.trim().isEmpty 
                      ? null 
                      : _notesController.text.trim(),
                  location: _selectedLocation,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

