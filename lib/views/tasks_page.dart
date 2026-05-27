import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                horizontal: 28,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4F46E5),
                    Color(0xFF8B5CF6),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'PrioriTask',
                style: GoogleFonts.roboto(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Task List
        Expanded(
          child: widget.schedule.tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/list-todo.svg',
                        width: 70,
                        colorFilter: ColorFilter.mode(
                          Colors.grey.withValues(alpha: 0.5),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No tasks yet. Tap + to add one!',
                        style: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
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
