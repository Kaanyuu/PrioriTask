import 'package:flutter/material.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  final Schedule schedule;

  const CalendarPage({super.key, required this.schedule});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CalendarDatePicker(
          initialDate: _focusedDay,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          onDateChanged: (DateTime date) {
            setState(() {
              _selectedDay = date;
            });
            //Logic to filter tasks goes here, this is to be changed.
          },
        ),
        const Divider(),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('Select a day to see tasks'))
              : _buildTaskListForDate(_selectedDay!),
        ),
      ],
    );
  }

  Widget _buildTaskListForDate(DateTime date) {
    // Filter tasks that match the selected date
    final tasksForDate = widget.schedule.tasks.where((task) {
      return task.deadline.year == date.year &&
             task.deadline.month == date.month &&
             task.deadline.day == date.day;
    }).toList();

    if (tasksForDate.isEmpty) {
      return const Center(child: Text('No tasks for this day.'));
    }

    return ListView.builder(
      itemCount: tasksForDate.length,
      itemBuilder: (context, index) {
        final task = tasksForDate[index];
        return ListTile(
          leading: const Icon(Icons.task_alt, color: Colors.amber),
          title: Text(task.name),
          subtitle: Text(task.description),
          trailing: Text(
            task.importance == 3 ? 'High' : (task.importance == 2 ? 'Medium' : 'Low'),
            style: TextStyle(
              color: task.importance == 3 ? Colors.red : (task.importance == 2 ? Colors.orange : Colors.green),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
