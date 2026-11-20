import 'package:flutter/material.dart';
import 'package:task_scheduler/features/tasks/models/task_model.dart';

class SwipeableTaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const SwipeableTaskCard({
    super.key,
    required this.task,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<SwipeableTaskCard> createState() => _SwipeableTaskCardState();
}

class _SwipeableTaskCardState extends State<SwipeableTaskCard> {
  double _dragOffset = 0.0;
  static const double _maxSlide = -62.0;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isCompleted = task.isCompleted;

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        // Revealed Circular Red Trash Button on the right (Matches Reference)
        Positioned(
          right: 6,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _dragOffset < -10 ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: () {
                setState(() => _dragOffset = 0.0);
                widget.onDelete();
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Foreground White Rounded Task Card
        GestureDetector(
          onTap: widget.onTap,
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dragOffset = (_dragOffset + details.delta.dx).clamp(
                _maxSlide,
                0.0,
              );
            });
          },
          onHorizontalDragEnd: (_) {
            setState(() {
              _dragOffset = _dragOffset < _maxSlide / 2 ? _maxSlide : 0.0;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F2937).withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Opacity(
              opacity: isCompleted ? 0.42 : 1.0,
              child: Row(
                children: [
                  // Purple Circular Checkbox / Radio
                  GestureDetector(
                    onTap: widget.onToggleComplete,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? const Color(0xFF6366F1)
                              : Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 1.8,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Task Title + Subtitle / Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                task.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.notes_rounded,
                                size: 14,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              task.dateLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: task.isOverdue && !isCompleted
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                            if (task.isOverdue && !isCompleted) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'OVERDUE',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right-side Priority Pill Badge (Low, Medium, High)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: task.priority.color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: task.priority.color.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      task.priority.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

