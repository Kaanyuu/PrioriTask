import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveService {
  static const String taskBoxName = 'tasks';

  static Future<Box<Task>> openTaskBox() async {
    return await Hive.openBox<Task>(taskBoxName);
  }

  static Future<void> addTask(Task task) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.put(task.id, task);
  }

  static List<Task> getTasks() {
    final box = Hive.box<Task>(taskBoxName);
    return box.values.toList();
  }

  static Future<void> deleteTask(String id) async {
    final box = Hive.box<Task>(taskBoxName);
    await box.delete(id);
  }

  static Future<void> saveAllTasks(List<Task> tasks) async {
    final box = Hive.box<Task>(taskBoxName);
    final Map<String, Task> taskMap = {for (var task in tasks) task.id: task};
    await box.putAll(taskMap);
  }
}

