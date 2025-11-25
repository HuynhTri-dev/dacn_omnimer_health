import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omnihealthmobileflutter/core/theme/app_colors.dart';
import 'package:omnihealthmobileflutter/domain/entities/goal_entity.dart';

class GoalFormScreen extends StatefulWidget {
  final String userId;
  final GoalEntity? existingGoal;

  const GoalFormScreen({super.key, required this.userId, this.existingGoal});

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _frequency;

  final List<String> _frequencies = ['Daily', 'Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _titleController = TextEditingController(text: widget.existingGoal!.title);
      _startDate = widget.existingGoal!.startDate;
      _endDate = widget.existingGoal!.endDate;
      _frequency = widget.existingGoal!.frequency;
    } else {
      _titleController = TextEditingController();
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(const Duration(days: 7));
      _frequency = _frequencies.first;
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final initialDate = isStart ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.textLight,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate!.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _startDate = _endDate!.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() != true) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
      );
      return;
    }

    final goal = GoalEntity(
      id: widget.existingGoal?.id,
      userId: widget.userId,
      title: _titleController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      frequency: _frequency!,
    );

    Navigator.pop(context, true); // Return true to indicate success

    // Add your API call or Bloc event to create/update this goal outside this widget as per architecture
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.existingGoal != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Cập nhật mục tiêu' : 'Tạo mục tiêu mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Mục tiêu'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập mục tiêu' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Ngày bắt đầu'),
                subtitle: Text(_formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(isStart: true),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Ngày kết thúc'),
                subtitle: Text(_formatDate(_endDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(isStart: false),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tần suất'),
                value: _frequency,
                items: _frequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _onSave,
                child: Text(isUpdate ? 'Cập nhật' : 'Tạo mới'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}