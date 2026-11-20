import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_scheduler/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:task_scheduler/features/tasks/views/widgets/add_edit_task_sheet.dart';
import 'package:task_scheduler/features/tasks/views/widgets/swipeable_task_card.dart';

class TaskCalendarView extends StatelessWidget {
  const TaskCalendarView({super.key});

  static const Color _primaryPurple = Color(0xFF6366F1);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Get.find<TaskViewModel>();

    return Column(
      children: [
        // Horizontal Date Strip Selector
        Container(
          height: 90,
          color: Colors.white,
          child: Obx(() {
            final selectedDate = taskViewModel.selectedCalendarDate.value;
            final now = DateTime.now();

            // 14-day window centered on today
            final days = List.generate(
              14,
              (index) => DateTime(now.year, now.month, now.day - 2 + index),
            );

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = day.year == selectedDate.year &&
                    day.month == selectedDate.month &&
                    day.day == selectedDate.day;
                final isToday = day.year == now.year &&
                    day.month == now.month &&
                    day.day == now.day;
                final tasksCount = taskViewModel.tasksForDate(day).length;

                return GestureDetector(
                  onTap: () => taskViewModel.setSelectedCalendarDate(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _primaryPurple
                          : isToday
                              ? _primaryPurple.withValues(alpha: 0.10)
                              : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _primaryPurple
                            : const Color(0xFFE5E7EB),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(day),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white70 : _textMuted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(day),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? _primaryPurple
                                    : _textDark,
                          ),
                        ),
                        if (tasksCount > 0) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : _primaryPurple,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // List of tasks scheduled for selected date
        Expanded(
          child: Obx(() {
            final selectedDate = taskViewModel.selectedCalendarDate.value;
            final dateTasks = taskViewModel.tasksForDate(selectedDate);
            final formattedHeader = DateFormat('EEEE, d MMMM').format(selectedDate);

            if (dateTasks.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available_rounded,
                        size: 56,
                        color: _primaryPurple.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'No tasks on $formattedHeader',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap the + button to schedule tasks for this day',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: _textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2, bottom: 12),
                  child: Text(
                    formattedHeader,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                ),
                ...dateTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SwipeableTaskCard(
                      task: task,
                      onToggleComplete: () =>
                          taskViewModel.toggleTaskCompletion(task),
                      onDelete: () => taskViewModel.deleteTask(task),
                      onTap: () {
                        AddEditTaskSheet.show(
                          context,
                          task: task,
                          onSave: ({
                            required String title,
                            required String description,
                            required DateTime dueDate,
                            required priority,
                          }) {
                            taskViewModel.updateTask(
                              task.copyWith(
                                title: title,
                                description: description,
                                dueDate: dueDate,
                                priority: priority,
                              ),
                            );
                          },
                          onDelete: () => taskViewModel.deleteTask(task),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

