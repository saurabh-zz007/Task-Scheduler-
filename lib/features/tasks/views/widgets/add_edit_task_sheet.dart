import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';

class AddEditTaskSheet extends StatefulWidget {
  final TaskModel? task;
  final Function({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) onSave;
  final VoidCallback? onDelete;

  const AddEditTaskSheet({
    super.key,
    this.task,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    TaskModel? task,
    required Function({
      required String title,
      required String description,
      required DateTime dueDate,
      required TaskPriority priority,
    }) onSave,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => AddEditTaskSheet(
        task: task,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<AddEditTaskSheet> {
  static const Color _primaryPurple = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF9CA3AF);

  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _selectedDueDate;
  late TaskPriority _selectedPriority;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleCtrl = TextEditingController(text: task?.title ?? '');
    _descCtrl = TextEditingController(text: task?.description ?? '');
    _selectedDueDate = task?.dueDate ?? DateTime.now().add(const Duration(hours: 2));
    _selectedPriority = task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryPurple,
              onPrimary: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryPurple,
              onPrimary: Colors.white,
              onSurface: _textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null || !mounted) return;

    setState(() {
      _selectedDueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  void _setQuickDate(int daysFromToday) {
    final now = DateTime.now();
    setState(() {
      _selectedDueDate = DateTime(
        now.year,
        now.month,
        now.day + daysFromToday,
        18, // 6:00 PM default end-of-workday
        0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Sheet Title Row with optional delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? 'Edit Task' : 'New Task',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              if (isEditing && widget.onDelete != null)
                IconButton(
                  tooltip: 'Delete task',
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onDelete!();
                  },
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Title Input Field
          TextField(
            controller: _titleCtrl,
            autofocus: !isEditing,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 15, color: _textDark),
            decoration: InputDecoration(
              hintText: 'What do you need to get done?',
              hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description Input Field (Optional)
          TextField(
            controller: _descCtrl,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(fontSize: 13.5, color: _textDark),
            decoration: InputDecoration(
              hintText: 'Add description or client details (optional)...',
              hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Due Date Label + Quick Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Due Date & Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 15,
                        color: _primaryPurple,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM, h:mm a').format(_selectedDueDate),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Date Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickDateChip('Today', 0),
                const SizedBox(width: 8),
                _buildQuickDateChip('Tomorrow', 1),
                const SizedBox(width: 8),
                _buildQuickDateChip('In 2 Days', 2),
                const SizedBox(width: 8),
                _buildQuickDateChip('Next Week', 7),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Priority Label & Selector
          const Text(
            'Priority',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: TaskPriority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(priority.label),
                  selected: isSelected,
                  selectedColor: priority.color,
                  backgroundColor: const Color(0xFFF3F4F6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : _textDark,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedPriority = priority);
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Submit Action Button
          ElevatedButton(
            onPressed: () {
              final title = _titleCtrl.text.trim();
              if (title.isEmpty) return;

              widget.onSave(
                title: title,
                description: _descCtrl.text.trim(),
                dueDate: _selectedDueDate,
                priority: _selectedPriority,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Text(
              isEditing ? 'Save Changes' : 'Add Task',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip(String label, int daysFromToday) {
    final now = DateTime.now();
    final targetDay = DateTime(now.year, now.month, now.day + daysFromToday);
    final isSelected = _selectedDueDate.year == targetDay.year &&
        _selectedDueDate.month == targetDay.month &&
        _selectedDueDate.day == targetDay.day;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: _primaryPurple.withValues(alpha: 0.15),
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: TextStyle(
        color: isSelected ? _primaryPurple : _textDark,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      onSelected: (_) => _setQuickDate(daysFromToday),
    );
  }
}

