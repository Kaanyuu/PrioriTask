import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class TasksPage extends StatefulWidget {
  final Schedule schedule;
  final Function(int) onTaskDeleted;

  const TasksPage({
    super.key,
    required this.schedule,
    required this.onTaskDeleted,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PrioriTask header/shape
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
                'PrioriTask',
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
          child: widget.schedule.tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Tap + to add one!'))
              : ListView.builder(
                  itemCount: widget.schedule.tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(
                      task: widget.schedule.tasks[index],
                      isExpanded: _expandedIndex == index,
                      onTap: () {
                        setState(() {
                          // Clicking expands/collapses task card
                          _expandedIndex = (_expandedIndex == index) ? null : index;
                        });
                      },
                      onDelete: () {
                        if (_expandedIndex == index) {
                          _expandedIndex = null;
                        } else if (_expandedIndex != null && _expandedIndex! > index) {
                          _expandedIndex = _expandedIndex! - 1;
                        }
                        widget.onTaskDeleted(index);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
