import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class CalendarPage extends StatefulWidget {
  final Schedule schedule;

  const CalendarPage({super.key, required this.schedule});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  // This filters task for a specific day(to be changed)
  List<Task> _getTasksForDay(DateTime day) {
    return widget.schedule.tasks.where((task) {
      return isSameDay(task.deadline, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            }
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          
          // Calendar Styling
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            weekendTextStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.red),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            formatButtonShowsNext: false, // This makes the label match the current view
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: const TextStyle(color: Colors.white),
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          // This adds markers (dots) for days that have tasks
          eventLoader: _getTasksForDay,
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
    final tasksForDate = _getTasksForDay(date);

    if (tasksForDate.isEmpty) {
      return const Center(child: Text('No tasks for this day.'));
    }

    return ListView.builder(
      itemCount: tasksForDate.length,
      itemBuilder: (context, index) {
        final task = tasksForDate[index];
        return ListTile(
          leading: const Icon(Icons.task_alt, color: Colors.amber),
          title: Text(task.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
