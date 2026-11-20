import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';

/// Pure Cloud Firestore service managing user tasks with real-time sync.
/// Operates directly against Cloud Firestore with zero local DB dependencies.
class TaskService {
  final FirebaseFirestore _firestore;

  TaskService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userTasksRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  /// Realtime stream of user tasks ordered chronologically by due date (earliest first).
  /// Uses includeMetadataChanges: true so pending local writes immediately emit.
  Stream<List<TaskModel>> getTasksStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<TaskModel>[]);
    }

    return _userTasksRef(userId)
        .orderBy('dueDate', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromFirestore(doc))
              .toList();
        })
        .handleError((error) {
          developer.log('Error streaming tasks for user $userId: $error');
          return <TaskModel>[];
        });
  }

  /// Explicitly fetch tasks once from Firestore.
  Future<List<TaskModel>> fetchTasks(String userId) async {
    if (userId.isEmpty) return <TaskModel>[];
    try {
      final snapshot = await _userTasksRef(userId)
          .orderBy('dueDate', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => TaskModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      developer.log('Error fetching tasks for user $userId: $e');
      return <TaskModel>[];
    }
  }

  /// Create a new task in Firestore.
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final collection = _userTasksRef(task.userId);
      final docRef = task.id.isNotEmpty ? collection.doc(task.id) : collection.doc();
      final taskWithId = task.copyWith(id: docRef.id);

      await docRef.set(taskWithId.toFirestore());
      return taskWithId;
    } catch (e) {
      developer.log('Error creating task: $e');
      throw Exception('Failed to create task: $e');
    }
  }

  /// Update an existing task in Firestore.
  Future<void> updateTask(TaskModel task) async {
    try {
      if (task.id.isEmpty) {
        throw Exception('Task ID cannot be empty for update.');
      }
      await _userTasksRef(task.userId).doc(task.id).update(task.toFirestore());
    } catch (e) {
      developer.log('Error updating task ${task.id}: $e');
      throw Exception('Failed to update task: $e');
    }
  }

  /// Toggle task completion flag with optimistic UI safety.
  Future<void> toggleTaskCompletion(String userId, String taskId, bool isCompleted) async {
    try {
      await _userTasksRef(userId).doc(taskId).update({
        'isCompleted': isCompleted,
      });
    } catch (e) {
      developer.log('Error toggling task completion for $taskId: $e');
      throw Exception('Failed to update completion status: $e');
    }
  }

  /// Delete a single task from Firestore immediately.
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _userTasksRef(userId).doc(taskId).delete();
    } catch (e) {
      developer.log('Error deleting task $taskId: $e');
      throw Exception('Failed to delete task: $e');
    }
  }

  /// Delete all completed tasks in a single atomic batch.
  Future<void> deleteCompletedTasks(String userId) async {
    try {
      final snapshot = await _userTasksRef(userId)
          .where('isCompleted', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      developer.log('Error clearing completed tasks for user $userId: $e');
      throw Exception('Failed to clear completed tasks: $e');
    }
  }

  /// Re-enable network connection to Cloud Firestore.
  Future<void> enableNetwork() async {
    try {
      await _firestore.enableNetwork();
      developer.log('Firestore network connection enabled.');
    } catch (e) {
      developer.log('Error enabling Firestore network: $e');
    }
  }

  /// Disable network connection to Cloud Firestore.
  Future<void> disableNetwork() async {
    try {
      await _firestore.disableNetwork();
      developer.log('Firestore network connection disabled.');
    } catch (e) {
      developer.log('Error disabling Firestore network: $e');
    }
  }
}
