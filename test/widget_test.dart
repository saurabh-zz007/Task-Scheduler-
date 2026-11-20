import 'package:flutter_test/flutter_test.dart';
import 'package:task_scheduler/core/constants/app_strings.dart';
import 'package:task_scheduler/features/auth/models/user_model.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';

void main() {
  test('AppStrings constants smoke test', () {
    expect(AppStrings.appName, 'Task Scheduler');
    expect(AppStrings.welcomeBack, 'Welcome Back');
    expect(AppStrings.createAccount, 'Create Account');
  });

  test('UserModel serialization and copyWith', () {
    const user = UserModel(
      uid: 'user_123',
      email: 'gigworker@example.com',
      displayName: 'Alex Rider',
      photoUrl: 'https://example.com/avatar.jpg',
    );

    final map = user.toMap();
    expect(map['uid'], 'user_123');
    expect(map['email'], 'gigworker@example.com');
    expect(map['displayName'], 'Alex Rider');

    final fromMapUser = UserModel.fromMap(map);
    expect(fromMapUser.uid, 'user_123');
    expect(fromMapUser.displayName, 'Alex Rider');

    final updated = user.copyWith(displayName: 'Alex Updated');
    expect(updated.displayName, 'Alex Updated');
    expect(updated.email, 'gigworker@example.com');
  });

  test('TaskModel serialization, priorities and sections', () {
    final now = DateTime.now();
    final todayTask = TaskModel(
      id: 'task_1',
      userId: 'user_1',
      title: 'Deliver package to client',
      description: 'Rush delivery for Downtown client',
      dueDate: DateTime(now.year, now.month, now.day, 14, 30),
      priority: TaskPriority.high,
      isCompleted: false,
      createdAt: now,
    );

    expect(todayTask.section, 'Today');
    expect(todayTask.priority, TaskPriority.high);
    expect(todayTask.priority.label, 'High');

    final map = todayTask.toMap();
    expect(map['title'], 'Deliver package to client');
    expect(map['priority'], 'high');

    final recreated = TaskModel.fromMap(map, id: 'task_1');
    expect(recreated.id, 'task_1');
    expect(recreated.title, 'Deliver package to client');
    expect(recreated.priority, TaskPriority.high);
    expect(recreated.isCompleted, false);

    // Overdue task test
    final overdueDate = now.subtract(const Duration(days: 2));
    final overdueTask = TaskModel(
      id: 'task_overdue',
      userId: 'user_1',
      title: 'Late report',
      dueDate: overdueDate,
      priority: TaskPriority.medium,
      createdAt: overdueDate,
    );
    expect(overdueTask.section, 'Overdue');
    expect(overdueTask.isOverdue, true);

    // Tomorrow task test
    final tomorrowDate = now.add(const Duration(days: 1));
    final tomorrowTask = TaskModel(
      id: 'task_tomorrow',
      userId: 'user_1',
      title: 'Meeting tomorrow',
      dueDate: tomorrowDate,
      priority: TaskPriority.low,
      createdAt: now,
    );
    expect(tomorrowTask.section, 'Tomorrow');
    expect(tomorrowTask.priority.label, 'Low');

    final completed = todayTask.copyWith(isCompleted: true);
    expect(completed.isCompleted, true);
  });
}
