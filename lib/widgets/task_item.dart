import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/edit_task_screen.dart';

class TaskItem extends StatefulWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.task.isCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Dismissible(
          key: Key(widget.task.id),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            taskProvider.deleteTask(widget.task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    taskProvider.addTask(
                      widget.task.title,
                      widget.task.description,
                    );
                  },
                ),
              ),
            );
          },
          child: Hero(
            tag: 'task-${widget.task.id}',
            child: Card(
              margin: EdgeInsets.zero,
              elevation: widget.task.isCompleted ? 1 : 2,
              color:
                  widget.task.isCompleted
                      ? theme.colorScheme.surface.withOpacity(0.7)
                      : null,
              child: Container(
                decoration:
                    widget.task.isCompleted
                        ? BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              width: 4,
                            ),
                          ),
                        )
                        : null,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(task: widget.task),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Row(
                      children: [
                        // Custom checkbox
                        InkWell(
                          onTap: () {
                            taskProvider.toggleTaskCompletion(widget.task.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color:
                                    widget.task.isCompleted
                                        ? theme.colorScheme.primary.withOpacity(
                                          _fadeAnimation.value,
                                        )
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color:
                                      widget.task.isCompleted
                                          ? theme.colorScheme.primary
                                              .withOpacity(_fadeAnimation.value)
                                          : theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child:
                                  widget.task.isCompleted
                                      ? Icon(
                                        Icons.check,
                                        size: 16,
                                        color: theme.colorScheme.onPrimary,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                        // Task content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: TextStyle(
                                    decoration:
                                        widget.task.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        widget.task.isCompleted
                                            ? theme.colorScheme.onSurface
                                                .withOpacity(
                                                  _fadeAnimation.value,
                                                )
                                            : theme.colorScheme.onSurface,
                                    fontWeight:
                                        widget.task.isCompleted
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (widget.task.description != null &&
                                    widget.task.description!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.task.description!,
                                    style: TextStyle(
                                      decoration:
                                          widget.task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                      color:
                                          widget.task.isCompleted
                                              ? theme.colorScheme.onSurface
                                                  .withOpacity(
                                                    _fadeAnimation.value * 0.7,
                                                  )
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
