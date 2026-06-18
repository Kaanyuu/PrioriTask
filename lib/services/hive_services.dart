import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveService {
  static const String taskBoxName = 'tasks';
  // Loading Task from phone data
  static Future<Box<Task>> openTaskBox() async {
    return await Hive.openBox<Task>(taskBoxName);
  }
  // Add tasks in phone data
  static Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.put(task.id, task);
  }
  // Get tasks in phone data
  static List<Task> getTasks() {
    final box = Hive.box<Task>(taskBoxName);
    return box.values.toList();
  }
  // Delete task in phone data
  static Future<void> deleteTask(String id) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.delete(id);
  }
  // Saves all current tasks in phone data
  static Future<void> saveAllTasks(List<Task> tasks) async {
    final box = Hive.box<Task>(taskBoxName);
    final Map<String, Task> taskMap = {for (var task in tasks) task.id: task};
    await box.putAll(taskMap);
  }
}

