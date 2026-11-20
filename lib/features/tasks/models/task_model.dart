import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981); // Emerald / Mint Green
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // Amber / Orange
      case TaskPriority.high:
        return const Color(0xFFEF4444); // Red / Coral
    }
  }

  static TaskPriority fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    required this.createdAt,
  });

  /// Factory constructor to map from Cloud Firestore document snapshot.
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return TaskModel.fromMap(data, id: doc.id);
  }

  /// Factory constructor from Map with optional explicit ID.
  factory TaskModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic value, DateTime fallback) {
      if (value == null) return fallback;
      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value) ?? fallback;
      return fallback;
    }

    final now = DateTime.now();

    return TaskModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueDate: parseDate(map['dueDate'], now),
      priority: TaskPriority.fromString(map['priority'] as String?),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      createdAt: parseDate(map['createdAt'], now),
    );
  }

  /// Convert to Firestore-compatible Map with native Timestamp objects.
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert to plain JSON Map (e.g. for offline cache).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Whether task due date has passed (prior to start of today).
  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(todayStart);
  }

  /// Computes human-readable date label matching UI design (e.g., '1 May', 'Today, 3:00 PM').
  String get dateLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final timeStr = DateFormat('h:mm a').format(dueDate);

    if (taskDay == today) {
      return 'Today, $timeStr';
    } else if (taskDay == tomorrow) {
      return 'Tomorrow, $timeStr';
    } else if (taskDay == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('d MMM').format(dueDate)}, $timeStr';
    }
  }

  /// Grouping section corresponding to the reference sections:
  /// 'Overdue', 'Today', 'Tomorrow', 'This week', 'Upcoming'.
  String get section {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDay.isBefore(today)) {
      return 'Overdue';
    } else if (taskDay == today) {
      return 'Today';
    } else if (taskDay == tomorrow) {
      return 'Tomorrow';
    } else {
      // Days until end of current week (Sunday)
      final daysUntilSunday = DateTime.sunday - now.weekday;
      final endOfWeek = today.add(Duration(days: daysUntilSunday + 1));
      if (taskDay.isBefore(endOfWeek)) {
        return 'This week';
      }
      return 'Upcoming';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          title == other.title &&
          description == other.description &&
          dueDate == other.dueDate &&
          priority == other.priority &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dueDate.hashCode ^
      priority.hashCode ^
      isCompleted.hashCode;
}

