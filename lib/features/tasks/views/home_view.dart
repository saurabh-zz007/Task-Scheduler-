import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_scheduler/core/services/network_service.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';
import 'package:task_scheduler/features/tasks/viewmodels/task_viewmodel.dart';
import 'package:task_scheduler/features/tasks/views/widgets/add_edit_task_sheet.dart';
import 'package:task_scheduler/features/tasks/views/widgets/swipeable_task_card.dart';
import 'package:task_scheduler/features/tasks/views/widgets/task_calendar_view.dart';
import 'package:task_scheduler/features/tasks/views/widgets/task_filter_account_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const Color _primaryPurple = Color(0xFF6366F1);
  static const Color _headerPurple = Color(0xFF7578F9);
  static const Color _bgOffWhite = Color(0xFFF7F8FC);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final TaskViewModel taskViewModel = Get.find<TaskViewModel>();
    final NetworkService networkService = Get.find<NetworkService>();

    return Scaffold(
      backgroundColor: _bgOffWhite,
      extendBody: true,
      body: Column(
        children: [
          // Thicker purple header section
          _buildHeader(context, taskViewModel),

          // Connectivity Warning or Reconnected Notification Bar
          _buildConnectivityBanner(networkService),

          // Main Task Body (List or Calendar)
          Expanded(
            child: Obx(() {
              if (taskViewModel.isLoading.value &&
                  taskViewModel.allTasks.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryPurple),
                  ),
                );
              }

              return taskViewModel.bottomNavIndex.value == 0
                  ? _buildTaskListBody(context, taskViewModel)
                  : const TaskCalendarView();
            }),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () => _openCreateTask(context, taskViewModel),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: _primaryPurple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withValues(alpha: 0.38),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(taskViewModel),
    );
  }

  /// Connectivity banner warning of offline state or confirming reconnection.
  Widget _buildConnectivityBanner(NetworkService network) {
    return Obx(() {
      if (network.isOffline.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFEF4444),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'No internet connection. Waiting for network to sync...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => network.checkConnectivity(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (network.showReconnectedNotice.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF10B981),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Back online! Ready to roll...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  /// Generously thick, spacious upper purple header.
  Widget _buildHeader(BuildContext context, TaskViewModel viewModel) {
    final nowFormatted = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _headerPurple,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circular shapes
          Positioned(
            top: -40,
            left: -35,
            child: Container(
              width: 195,
              height: 195,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: -45,
            child: Container(
              width: 155,
              height: 155,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: [Grid Filter] [Pill Search Bar] [••• Menu]
                  Row(
                    children: [
                      // UPPER-LEFT BUTTON: Category Filter Sheet
                      Obx(() {
                        final hasActiveFilter =
                            viewModel.selectedPriorityFilter.value !=
                            TaskPriorityFilter.all;

                        return InkWell(
                          onTap: () => TaskFilterAccountSheet.show(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.grid_view_rounded,
                              color: hasActiveFilter
                                  ? const Color(0xFFFDE047)
                                  : Colors.white,
                              size: 24,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 14),

                      // Guaranteed True Pill Search Bar
                      Expanded(
                        child: Container(
                          height: 42,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Obx(() {
                            final activeFilter =
                                viewModel.selectedPriorityFilter.value;
                            final query = viewModel.searchQuery.value;

                            return TextField(
                              onChanged: viewModel.setSearchQuery,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: _textDark,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                hintText: activeFilter == TaskPriorityFilter.all
                                    ? 'Search tasks...'
                                    : 'Filtered: ${activeFilter.label}',
                                hintStyle: const TextStyle(
                                  color: _textMuted,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: _textMuted,
                                  size: 19,
                                ),
                                suffixIcon: query.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () =>
                                            viewModel.setSearchQuery(''),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: _textMuted,
                                          size: 17,
                                        ),
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 11,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // UPPER-RIGHT BUTTON: List Options Menu (•••)
                      Obx(() {
                        final showDone = viewModel.showCompleted.value;
                        final isFiltered =
                            viewModel.selectedPriorityFilter.value !=
                                TaskPriorityFilter.all ||
                            viewModel.searchQuery.value.isNotEmpty;

                        return PopupMenuButton<String>(
                          offset: const Offset(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          onSelected: (value) {
                            if (value == 'toggle_completed') {
                              viewModel.toggleShowCompleted();
                            } else if (value == 'clear_completed') {
                              viewModel.clearCompletedTasks();
                            } else if (value == 'reset_filters') {
                              viewModel.resetFilters();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle_completed',
                              child: Row(
                                children: [
                                  Icon(
                                    showDone
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 19,
                                    color: _textDark,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    showDone
                                        ? 'Hide completed'
                                        : 'Show completed',
                                    style: const TextStyle(fontSize: 13.5),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'clear_completed',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_sweep_outlined,
                                    size: 19,
                                    color: Color(0xFFEF4444),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Clear completed',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFFEF4444),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isFiltered)
                              const PopupMenuItem(
                                value: 'reset_filters',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.filter_alt_off_outlined,
                                      size: 19,
                                      color: _primaryPurple,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Reset filters',
                                      style: TextStyle(fontSize: 13.5),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.more_horiz_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),

                  // Generous vertical breathing room
                  const SizedBox(height: 28),

                  // Bottom Title & Count Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nowFormatted,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.88),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'My tasks',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      // Task Pending / Filter summary badge
                      Obx(() {
                        final pendingCount = viewModel.allTasks
                            .where((t) => !t.isCompleted)
                            .length;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Text(
                            '$pendingCount pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskListBody(BuildContext context, TaskViewModel viewModel) {
    final sections = viewModel.activeSections;

    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 64,
                color: _primaryPurple.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              const Text(
                'No tasks to show',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                viewModel.allTasks.isEmpty
                    ? 'Stay productive! Tap the + button to create your first task.'
                    : 'No tasks match your active filters or search query.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _textMuted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (viewModel.allTasks.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: viewModel.resetFilters,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Reset filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryPurple,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _openCreateTask(context, viewModel),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add Task'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryPurple,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 100),
      physics: const BouncingScrollPhysics(),
      children: [
        for (final section in sections) ...[
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 12, top: 4),
            child: Row(
              children: [
                Text(
                  section,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: section == 'Overdue'
                        ? const Color(0xFFEF4444)
                        : _textDark,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: section == 'Overdue'
                        ? const Color(0xFFEF4444).withValues(alpha: 0.12)
                        : _primaryPurple.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${viewModel.tasksForSection(section).length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: section == 'Overdue'
                          ? const Color(0xFFEF4444)
                          : _primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...viewModel
              .tasksForSection(section)
              .map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SwipeableTaskCard(
                    task: task,
                    onToggleComplete: () =>
                        viewModel.toggleTaskCompletion(task),
                    onDelete: () => viewModel.deleteTask(task),
                    onTap: () => _openEditTask(context, viewModel, task),
                  ),
                ),
              ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildBottomNavBar(TaskViewModel viewModel) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() {
        final currentIndex = viewModel.bottomNavIndex.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Left Tab: Task List
            IconButton(
              onPressed: () => viewModel.setBottomNavIndex(0),
              icon: Icon(
                Icons.format_list_bulleted_rounded,
                size: 27,
                color: currentIndex == 0 ? _primaryPurple : _textMuted,
              ),
            ),
            const SizedBox(width: 48), // Gap for center docked FAB
            // Right Tab: Calendar View
            IconButton(
              onPressed: () => viewModel.setBottomNavIndex(1),
              icon: Icon(
                Icons.calendar_today_outlined,
                size: 24,
                color: currentIndex == 1 ? _primaryPurple : _textMuted,
              ),
            ),
          ],
        );
      }),
    );
  }

  void _openCreateTask(BuildContext context, TaskViewModel viewModel) {
    AddEditTaskSheet.show(
      context,
      onSave:
          ({
            required String title,
            required String description,
            required DateTime dueDate,
            required priority,
          }) {
            viewModel.createTask(
              title: title,
              description: description,
              dueDate: dueDate,
              priority: priority,
            );
          },
    );
  }

  void _openEditTask(
    BuildContext context,
    TaskViewModel viewModel,
    TaskModel task,
  ) {
    AddEditTaskSheet.show(
      context,
      task: task,
      onSave:
          ({
            required String title,
            required String description,
            required DateTime dueDate,
            required priority,
          }) {
            viewModel.updateTask(
              task.copyWith(
                title: title,
                description: description,
                dueDate: dueDate,
                priority: priority,
              ),
            );
          },
      onDelete: () => viewModel.deleteTask(task),
    );
  }
}
