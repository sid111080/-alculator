import 'package:hive/hive.dart';

/// Сервис трекинга завершённых заданий.
/// Хранит список id выполненных заданий (требование 8.8).
class TaskService {
  TaskService._();
  static final TaskService _instance = TaskService._();
  factory TaskService() => _instance;

  static const String _boxName = 'completed_tasks';
  late Box<String> _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Завершено ли задание с данным id.
  bool isCompleted(String taskId) => _box.containsKey(taskId);

  /// Отметить задание как завершённое.
  void markCompleted(String taskId) => _box.put(taskId, DateTime.now().toIso8601String());

  /// Список завершённых id.
  List<String> completedIds() => _box.keys.cast<String>().toList();

  /// Количество завершённых.
  int get completedCount => _box.length;

  /// Сброс (при удалении профиля).
  Future<void> clearAll() => _box.clear();
}
