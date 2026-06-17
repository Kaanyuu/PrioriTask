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
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = selectedDay;
            });
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
          // Calendar Styling
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(4),
            tableBorder: TableBorder.all(color: Colors.grey.withValues(alpha: 0.3)), // Adds the grid lines
            // Today highlight
            todayDecoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 2),
              shape: BoxShape.circle,
            ),
            todayTextStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
            // Selected highlight
            selectedDecoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            weekendTextStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.red),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            formatButtonShowsNext: false,
            titleCentered: true,
            formatButtonDecoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20.0),
            ),
            formatButtonTextStyle: const TextStyle(color: Colors.white),
            titleTextStyle: GoogleFonts.inter(
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          eventLoader: _getTasksForDay,
          // Custom Week Name Styling
          calendarBuilders: CalendarBuilders(
            dowBuilder: (context, day) {
              final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
              final text = days[day.weekday % 7];
              return Center(
                child: Text(
                  text,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: day.weekday == DateTime.sunday || day.weekday == DateTime.saturday 
                        ? Colors.red 
                        : Colors.black87,
                  ),
                ),
              );
            },
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return const SizedBox();
              
              final tasks = events.cast<Task>();
              bool hasHigh = tasks.any((t) => t.importance >= 0.9);
              bool hasMedium = tasks.any((t) => t.importance >= 0.6 && t.importance < 0.9);
              bool hasLow = tasks.any((t) => t.importance < 0.6);

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasHigh) _buildMarker(Colors.red),
                  if (hasMedium) _buildMarker(Colors.orange),
                  if (hasLow) _buildMarker(Colors.green),
                ],
              );
            },
          ),
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
  // Marker Section
  Widget _buildMarker(Color color) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  //Task list
  Widget _buildTaskListForDate(DateTime date) {
    final tasksForDate = _getTasksForDay(date);

    if (tasksForDate.isEmpty) {
      return const Center(child: Text('No tasks for this day.'));
    }

    return ListView.builder(
      itemCount: tasksForDate.length,
      itemBuilder: (context, index) {
        final task = tasksForDate[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: ListTile(
            leading: const Icon(Icons.task_alt, color: Colors.amber),
            title: Text(task.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description),
                Text(
                  "${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: task.importance >= 0.9 
                    ? const Color(0xFFEF4444)
                    : (task.importance >= 0.6 
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                task.importance >= 0.9 ? 'High' : (task.importance >= 0.6 ? 'Medium' : 'Low'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
