import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';
import '../widgets/edit_task_prompt.dart';

class TasksPage extends StatefulWidget {
  final Schedule schedule;
  final Function(int) onTaskDeleted;
  final Function(int) onTaskCompleted;
  final Function(int, Task) onTaskEdit;

  const TasksPage({
    super.key,
    required this.schedule,
    required this.onTaskDeleted,
    required this.onTaskCompleted,
    required this.onTaskEdit,
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
                style: GoogleFonts.inter(
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
                        style: GoogleFonts.inter(
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
                    final task = widget.schedule.tasks[index];

                    // COMPLETE TO SLIDE
                    return Dismissible(
                      key: Key(task.name + task.deadline.toString()),
                      direction: DismissDirection.horizontal,
                      movementDuration: const Duration(milliseconds: 250),
                      resizeDuration: const Duration(milliseconds: 300),
                      dismissThresholds: const {
                        DismissDirection.startToEnd: 0.4,
                        DismissDirection.endToStart: 0.4,
                      },
                      background: _buildSwipeBackgroundComplete(),
                      secondaryBackground: _buildSwipeBackgroundDelete(),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                        return await _confirmComplete(context, task);
                        } else {
                          return await _confirmDelete(context, task);
                        }
                      },
                      onDismissed: (direction) {
                        setState(() {
                          if (_expandedIndex == index) {
                            _expandedIndex = null;
                          } else if (_expandedIndex != null && _expandedIndex! > index) {
                            _expandedIndex = _expandedIndex! - 1;
                          }
                        });
                        if (direction == DismissDirection.startToEnd) {
                          widget.onTaskCompleted(index);
                        } else {
                          widget.onTaskDeleted(index);
                        }
                      },

                      child: TaskCard(
                        task: task,
                        index: index,
                        onTaskCompleted: widget.onTaskCompleted,
                        isExpanded: _expandedIndex == index,
                        // TAP TO EXPAND
                        onTap: () {
                          setState(() {
                            _expandedIndex = (_expandedIndex == index) ? null : index;
                          });
                        },
                        // TAP TO EDIT
                        onEdit: () async {
                          Task? updatedTask = await showEditTaskForm(context, widget.schedule, index);

                          if (updatedTask != null) {
                            setState(() {
                              widget.schedule.tasks[index] = updatedTask; // replace old task with edited one
                              recomputeAll(widget.schedule); // recompute since values changed
                            });
                            // saveSchedules([widget.schedule]); // persist if local storage is set up
                          }
                        },
                        // HOLD TO DUPLICATE
                      ),
                    );
                  },
          )
        ),
      ],

    );
  }

  // CONFIRM COMPLETE (DON'T CHANGE)
  bool dontShowAgainComplete = false;
  Future<bool> _confirmComplete(BuildContext context, Task task) async {
    if (dontShowAgainComplete) {
      return true; // skip dialog entirely if user opted out
    }

    bool tempDontShow = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mark as complete?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete "${task.name}"?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: tempDontShow,
                    onChanged: (value) {
                      setDialogState(() {
                        tempDontShow = value ?? false;
                      });
                    },
                  ),
                  const Text("Don't show this again", style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );

    if (result == true && tempDontShow) {
      setState(() {
        dontShowAgainComplete = true;
      });
    }

    return result ?? false;
  }

  // CONFIRM DELETE (DON'T CHANGE)
  Future<bool> _confirmDelete(BuildContext context, Task task) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Delete "${task.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // FOR COMPLETE BACKGROUND (DON'T CHANGE)
  Widget _buildSwipeBackgroundComplete() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF639922).withValues(alpha: 0.050), // soft green
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        children: const [
          Icon(Icons.check_circle_rounded, color: Color(0xFF3B6D11), size: 26),
          SizedBox(width: 8),
          Text(
            'Complete',
            style: TextStyle(
              color: Color(0xFF3B6D11),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSwipeBackgroundDelete() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF47174).withValues(alpha: 0.050), // soft green
      borderRadius: BorderRadius.circular(16),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 24),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: const [
        Icon(Icons.cancel_rounded, color: Color(0xFFF47174), size: 26),
        SizedBox(width: 8),
        Text(
          'Delete',
          style: TextStyle(
            color: Color(0xFFF47174),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}



