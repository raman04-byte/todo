import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/task_service.dart';

enum TaskFilter { all, active, completed }

class TaskProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeModeKey = 'theme_mode';

  List<Task> get tasks {
    switch (_filter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
    }
  }

  TaskFilter get filter => _filter;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;

  TaskProvider() {
    loadTasks();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null) {
        _themeMode = ThemeMode.values[themeModeIndex];
        notifyListeners();
      }
    } catch (e) {
      print('Error loading theme mode: $e');
    }
  }

  Future<void> toggleThemeMode() async {
    try {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, _themeMode.index);
      notifyListeners();
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _taskService.getTasks();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  Future<void> addTask(String title, String? description) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
    );

    try {
      await _taskService.addTask(task);
      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _taskService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String id) async {
    try {
      await _taskService.toggleTaskCompletion(id);
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(
          isCompleted: !_tasks[index].isCompleted,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }
}
