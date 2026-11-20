import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_scheduler/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:task_scheduler/features/tasks/viewmodels/task_viewmodel.dart';

class TaskFilterAccountSheet extends StatelessWidget {
  const TaskFilterAccountSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => const TaskFilterAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskViewModel = Get.find<TaskViewModel>();
    final authViewModel = Get.find<AuthViewModel>();

    const primaryPurple = Color(0xFF6366F1);
    const textDark = Color(0xFF1F2937);
    const textMuted = Color(0xFF9CA3AF);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by Priority',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              Obx(() {
                if (taskViewModel.selectedPriorityFilter.value !=
                    TaskPriorityFilter.all) {
                  return TextButton(
                    onPressed: () {
                      taskViewModel.setPriorityFilter(TaskPriorityFilter.all);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryPurple,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Priority Filter Chips
          Obx(() {
            final activeFilter = taskViewModel.selectedPriorityFilter.value;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TaskPriorityFilter.values.map((filter) {
                final isSelected = activeFilter == filter;
                return ChoiceChip(
                  label: Text(filter.label),
                  selected: isSelected,
                  selectedColor: primaryPurple,
                  backgroundColor: const Color(0xFFF3F4F6),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  onSelected: (_) {
                    taskViewModel.setPriorityFilter(filter);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            );
          }),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Divider(height: 1),
          ),

          // User Account Information & Sign Out
          Obx(() {
            final user = authViewModel.currentUser.value;
            final displayName = user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : (user?.email?.split('@').first ?? 'Gig Worker');
            final email = user?.email ?? 'Logged in user';

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: primaryPurple.withValues(alpha: 0.12),
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : null,
                child: user?.photoUrl == null
                    ? Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: primaryPurple,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              title: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: textDark,
                ),
              ),
              subtitle: Text(
                email,
                style: const TextStyle(fontSize: 12, color: textMuted),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _confirmSignOut(context, authViewModel);
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFFEF4444),
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthViewModel authViewModel) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Get.back();
              authViewModel.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

