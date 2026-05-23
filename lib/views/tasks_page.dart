import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class TasksPage extends StatelessWidget {
  final Schedule schedule;
  final Function(int) onTaskDeleted;

  const TasksPage({
    super.key,
    required this.schedule,
    required this.onTaskDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Schedule header shape and position
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.amberAccent,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                schedule.name,
                style: GoogleFonts.poppins(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Task List
        Expanded(
          child: schedule.tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Tap + to add one!'))
              : ListView.builder(
                  itemCount: schedule.tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: schedule.tasks[index],
                      onDelete: () => onTaskDeleted(index),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
