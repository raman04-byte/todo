import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final themeMode = taskProvider.themeMode;
    final isDarkMode = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            floating: true,
            elevation: 0,
            title: const Text(
              'My Tasks',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              // Theme toggle button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      key: ValueKey<bool>(isDarkMode),
                      color: isDarkMode ? Colors.amber : Colors.blueGrey,
                    ),
                  ),
                  tooltip:
                      isDarkMode
                          ? 'Switch to Light Mode'
                          : 'Switch to Dark Mode',
                  onPressed: () {
                    taskProvider.toggleThemeMode();
                  },
                ),
              ),
              // Filter menu
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: PopupMenuButton<TaskFilter>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (filter) {
                    taskProvider.setFilter(filter);
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: TaskFilter.all,
                          child: Row(
                            children: [
                              Icon(
                                Icons.list,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Text('All'),
                              const SizedBox(width: 8),
                              if (taskProvider.filter == TaskFilter.all)
                                Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TaskFilter.active,
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_unchecked,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Active'),
                              const SizedBox(width: 8),
                              if (taskProvider.filter == TaskFilter.active)
                                Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: TaskFilter.completed,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              const Text('Completed'),
                              const SizedBox(width: 8),
                              if (taskProvider.filter == TaskFilter.completed)
                                Icon(
                                  Icons.check,
                                  color: theme.colorScheme.primary,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ],
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _buildFilterChips(context, taskProvider)),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              if (taskProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final tasks = taskProvider.tasks;

              if (tasks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 96,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _getEmptyMessage(taskProvider.filter),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap the + button to add a new task',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: TaskItem(task: task),
                    );
                  }, childCount: tasks.length),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilterChips(BuildContext context, TaskProvider taskProvider) {
    final theme = Theme.of(context);
    final currentFilter = taskProvider.filter;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: currentFilter == TaskFilter.all,
              onSelected: (selected) {
                if (selected) taskProvider.setFilter(TaskFilter.all);
              },
              avatar: Icon(
                Icons.list,
                color:
                    currentFilter == TaskFilter.all
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                size: 18,
              ),
              showCheckmark: false,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Active'),
              selected: currentFilter == TaskFilter.active,
              onSelected: (selected) {
                if (selected) taskProvider.setFilter(TaskFilter.active);
              },
              avatar: Icon(
                Icons.radio_button_unchecked,
                color:
                    currentFilter == TaskFilter.active
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                size: 18,
              ),
              showCheckmark: false,
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Completed'),
              selected: currentFilter == TaskFilter.completed,
              onSelected: (selected) {
                if (selected) taskProvider.setFilter(TaskFilter.completed);
              },
              avatar: Icon(
                Icons.check_circle_outline,
                color:
                    currentFilter == TaskFilter.completed
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                size: 18,
              ),
              showCheckmark: false,
            ),
          ],
        ),
      ),
    );
  }

  String _getEmptyMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'No tasks yet';
      case TaskFilter.active:
        return 'No active tasks';
      case TaskFilter.completed:
        return 'No completed tasks';
    }
  }
}
