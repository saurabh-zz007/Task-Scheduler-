import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/core/services/network_service.dart';
import 'package:task_scheduler/core/theme/app_theme.dart';
import 'package:task_scheduler/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';
import 'package:task_scheduler/features/tasks/services/task_service.dart';

enum TaskPriorityFilter {
  all,
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case TaskPriorityFilter.all:
        return 'All';
      case TaskPriorityFilter.high:
        return 'High';
      case TaskPriorityFilter.medium:
        return 'Medium';
      case TaskPriorityFilter.low:
        return 'Low';
    }
  }
}

class TaskViewModel extends GetxController {
  final TaskService _taskService;
  final AuthViewModel _authViewModel;

  TaskViewModel({TaskService? taskService, AuthViewModel? authViewModel})
      : _taskService = taskService ?? TaskService(),
        _authViewModel = authViewModel ?? Get.find<AuthViewModel>();

  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final Rx<TaskPriorityFilter> selectedPriorityFilter =
      TaskPriorityFilter.all.obs;
  final RxBool showCompleted = true.obs;
  final RxInt bottomNavIndex = 0.obs; // 0 = Tasks List, 1 = Calendar View
  final Rx<DateTime> selectedCalendarDate = DateTime.now().obs;

  StreamSubscription<List<TaskModel>>? _tasksSubscription;
  StreamSubscription? _userAuthSubscription;
  StreamSubscription? _networkSubscription;

  @override
  void onInit() {
    super.onInit();

    final initialUser = _authViewModel.currentUser.value;
    if (initialUser != null) {
      _subscribeToUserTasks(initialUser.uid);
    }

    _userAuthSubscription = _authViewModel.currentUser.listen((user) {
      if (user != null) {
        _subscribeToUserTasks(user.uid);
      } else {
        _tasksSubscription?.cancel();
        allTasks.clear();
      }
    });

    // Listen to network reconnection to restore Firestore network & refresh tasks
    if (Get.isRegistered<NetworkService>()) {
      final network = Get.find<NetworkService>();
      _networkSubscription = network.isOffline.listen((offline) {
        if (!offline) {
          _taskService.enableNetwork();
          refreshTasks();
        }
      });
    }
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _userAuthSubscription?.cancel();
    _networkSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToUserTasks(String userId) {
    _tasksSubscription?.cancel();
    isLoading.value = true;
    _tasksSubscription = _taskService
        .getTasksStream(userId)
        .listen(
          (tasks) {
            allTasks.assignAll(tasks);
            isLoading.value = false;
          },
          onError: (err) {
            isLoading.value = false;
            developer.log('Error streaming tasks: $err');
            showErrorSnackbar('Failed to sync tasks: $err');
          },
        );
  }

  /// Explicitly re-sync user tasks from Cloud Firestore.
  Future<void> refreshTasks() async {
    final user = _authViewModel.currentUser.value;
    if (user != null && user.uid.isNotEmpty) {
      try {
        final tasks = await _taskService.fetchTasks(user.uid);
        if (tasks.isNotEmpty || allTasks.isEmpty) {
          allTasks.assignAll(tasks);
        }
      } catch (e) {
        developer.log('Error refreshing tasks: $e');
      }
    }
  }

  List<TaskModel> get filteredTasks {
    final query = searchQuery.value.trim().toLowerCase();
    final priority = selectedPriorityFilter.value;
    final showDone = showCompleted.value;

    final result = allTasks.where((task) {
      if (!showDone && task.isCompleted) return false;

      if (priority != TaskPriorityFilter.all &&
          task.priority.name != priority.name) {
        return false;
      }

      if (query.isNotEmpty) {
        final titleMatch = task.title.toLowerCase().contains(query);
        final descMatch = task.description.toLowerCase().contains(query);
        if (!titleMatch && !descMatch) return false;
      }

      return true;
    }).toList();

    result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return result;
  }

  List<TaskModel> tasksForSection(String section) {
    return filteredTasks.where((task) => task.section == section).toList();
  }

  List<String> get activeSections {
    const canonicalOrder = [
      'Overdue',
      'Today',
      'Tomorrow',
      'This week',
      'Upcoming',
    ];
    return canonicalOrder
        .where((sec) => tasksForSection(sec).isNotEmpty)
        .toList();
  }

  List<TaskModel> tasksForDate(DateTime date) {
    final target = DateTime(date.year, date.month, date.day);
    return allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate == target;
    }).toList()..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void setPriorityFilter(TaskPriorityFilter filter) {
    selectedPriorityFilter.value = filter;
  }

  void toggleShowCompleted() {
    showCompleted.value = !showCompleted.value;
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedPriorityFilter.value = TaskPriorityFilter.all;
    showCompleted.value = true;
  }

  void setBottomNavIndex(int index) {
    bottomNavIndex.value = index;
  }

  void setSelectedCalendarDate(DateTime date) {
    selectedCalendarDate.value = date;
  }

  /// Create a new task in Firestore and immediately reflect in UI.
  Future<bool> createTask({
    required String title,
    String description = '',
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    final user = _authViewModel.currentUser.value;
    if (user == null || user.uid.isEmpty) {
      showErrorSnackbar('You must be signed in to create a task.');
      return false;
    }

    try {
      final newTask = TaskModel(
        id: '',
        userId: user.uid,
        title: title.trim(),
        description: description.trim(),
        dueDate: dueDate,
        priority: priority,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final createdTask = await _taskService.createTask(newTask);

      // Immediately reflect the created task into the reactive list
      final idx = allTasks.indexWhere((t) => t.id == createdTask.id);
      if (idx == -1) {
        allTasks.add(createdTask);
      } else {
        allTasks[idx] = createdTask;
      }

      showSuccessSnackbar('Task added successfully!');
      return true;
    } catch (e) {
      showErrorSnackbar('Failed to create task: $e');
      return false;
    }
  }

  /// Update an existing task in Firestore and immediate local reflect.
  Future<bool> updateTask(TaskModel task) async {
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      allTasks[index] = task;
    }

    try {
      await _taskService.updateTask(task);
      showSuccessSnackbar('Task updated!');
      return true;
    } catch (e) {
      showErrorSnackbar('Failed to update task: $e');
      return false;
    }
  }

  /// Immediate optimistic toggle of task completion.
  Future<void> toggleTaskCompletion(TaskModel task) async {
    final nextState = !task.isCompleted;

    // Optimistic local update
    final index = allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      allTasks[index] = task.copyWith(isCompleted: nextState);
    }

    try {
      await _taskService.toggleTaskCompletion(task.userId, task.id, nextState);
    } catch (e) {
      // Revert if call fails
      if (index != -1) {
        allTasks[index] = task;
      }
      showErrorSnackbar('Failed to update completion: $e');
    }
  }

  /// Immediately delete task from Firestore so restart never resurrects it,
  /// with undo support restoring the task to both Firestore and UI.
  Future<void> deleteTask(TaskModel task) async {
    final removedIndex = allTasks.indexWhere((t) => t.id == task.id);
    if (removedIndex != -1) {
      allTasks.removeAt(removedIndex);
    }

    // Immediately execute Firestore deletion
    try {
      await _taskService.deleteTask(task.userId, task.id);
    } catch (e) {
      // Revert local removal if delete failed
      if (removedIndex != -1 && removedIndex <= allTasks.length) {
        allTasks.insert(removedIndex, task);
      } else {
        allTasks.add(task);
      }
      showErrorSnackbar('Error removing task from cloud: $e');
      return;
    }

    // Provide non-intrusive Undo snackbar
    Get.rawSnackbar(
      messageText: Text(
        'Task "${task.title}" deleted',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      mainButton: TextButton(
        onPressed: () async {
          if (Get.isSnackbarOpen) Get.back();
          // Restore task to Firestore & reactive list
          try {
            final restored = await _taskService.createTask(task);
            final exists = allTasks.any((t) => t.id == restored.id);
            if (!exists) {
              if (removedIndex != -1 && removedIndex <= allTasks.length) {
                allTasks.insert(removedIndex, restored);
              } else {
                allTasks.add(restored);
              }
            }
          } catch (e) {
            showErrorSnackbar('Failed to restore task: $e');
          }
        },
        child: const Text(
          'UNDO',
          style: TextStyle(
            color: Color(0xFFFDE047),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1F2937),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      borderRadius: 14,
    );
  }

  /// Delete all completed tasks in a batch.
  Future<void> clearCompletedTasks() async {
    final user = _authViewModel.currentUser.value;
    if (user == null) return;

    final completedTasks = allTasks.where((t) => t.isCompleted).toList();
    if (completedTasks.isEmpty) {
      showInfoSnackbar('No completed tasks to clear.');
      return;
    }

    // Optimistic clear
    allTasks.removeWhere((t) => t.isCompleted);

    try {
      await _taskService.deleteCompletedTasks(user.uid);
      showSuccessSnackbar('Cleared ${completedTasks.length} completed tasks!');
    } catch (e) {
      // Re-insert on error
      allTasks.addAll(completedTasks);
      showErrorSnackbar('Failed to clear completed tasks: $e');
    }
  }

  // Feedback Helpers
  void showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.successColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
    );
  }

  void showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    );
  }

  void showInfoSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'Notice',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1F2937).withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }
}
