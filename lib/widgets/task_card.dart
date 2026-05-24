import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          task.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text("${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}", 
                  style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                const Icon(Icons.priority_high, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  task.importance >= 0.9 ? 'High' : (task.importance >= 0.6 ? 'Medium' : 'Low'),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
