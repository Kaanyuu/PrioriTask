import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/task.dart';

Future<Task?> showAddTaskPrompt(BuildContext context, Schedule currentSchedule) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Initialized properly to match the preselected
  double taskDifficulty = 1.0; 
  double taskImportance = 1.0;

  // Task Name Section
  String? taskName = await showDialog<String>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.only(right: 24, bottom: 12),
        title: Text(
          'Task Name',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: nameController,
            autofocus: true,
            style: GoogleFonts.roboto(fontSize: 14),
            onChanged: (value) {
              setDialogState(() {});
            },
            decoration: InputDecoration(
              hintText: "What needs to be done?",
              hintStyle: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.withValues(alpha: 0.6)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.amber),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.amber, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.amber, width: 2),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: nameController.text.isEmpty
                ? null
                : () {
                    Navigator.pop(context, nameController.text);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text('Next', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  if (taskName == null || taskName.isEmpty) return null;
  if (!context.mounted) return null;

  // Select Date Section
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  DateTime? taskDeadline = await showDialog<DateTime>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        actionsPadding: const EdgeInsets.only(right: 24, bottom: 12),
        title: Text(
          'Select Deadline',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime(2101),
                focusedDay: focusedDay,
                currentDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 16),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black54),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black54),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
                  weekendStyle: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  defaultTextStyle: GoogleFonts.roboto(fontSize: 14),
                  weekendTextStyle: GoogleFonts.roboto(fontSize: 14),
                  todayDecoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: GoogleFonts.roboto(color: Colors.amber, fontWeight: FontWeight.bold),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: (selected, focused) {
                  setDialogState(() {
                    selectedDay = selected;
                    focusedDay = focused;
                  });
                },
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedDay == null
                      ? 'No date selected'
                      : _formatFullDate(selectedDay!),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: selectedDay == null
                ? null
                : () => Navigator.pop(context, selectedDay),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              disabledBackgroundColor: Colors.grey.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text('Next', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  if (taskDeadline == null) return null;
  if (!context.mounted) return null;

  // Description, Difficulty and Importance Section
  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        actionsPadding: const EdgeInsets.only(right: 24, bottom: 12),
        title: Text(
          'Final Details',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // DESCRIPTION
                TextField(
                  controller: descriptionController,
                  style: GoogleFonts.roboto(fontSize: 14),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.amber, width: 2),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // DIFFICULTY
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Difficulty',
                  style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 4),
              RatingBar.builder(
                initialRating: taskDifficulty,
                minRating: 1,
                maxRating: 5,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                itemBuilder: (context, _) => SvgPicture.asset(
                  'assets/star.svg',
                  colorFilter: const ColorFilter.mode(
                    Colors.amber,
                    BlendMode.srcIn,
                  ),
                ),
                onRatingUpdate: (rating) {
                  setDialogState(() {
                    taskDifficulty = rating;
                  });
                },
              ),
              const SizedBox(height: 16),

              // IMPORTANCE
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Importance',
                  style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildImportanceOption(
                    label: 'Low',
                    isSelected: taskImportance == 1,
                    color: const Color(0xFF10B981),
                    onTap: () => setDialogState(() {
                      taskImportance = 1;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildImportanceOption(
                    label: 'Medium',
                    isSelected: taskImportance == 2,
                    color: const Color(0xFFF59E0B),
                    onTap: () => setDialogState(() {
                      taskImportance = 2;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _buildImportanceOption(
                    label: 'High',
                    isSelected: taskImportance == 3,
                    color: const Color(0xFFEF4444),
                    onTap: () => setDialogState(() {
                      taskImportance = 3;
                    }),
                  ),
                ],
              ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.grey, fontWeight: FontWeight.w500)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 0,
            ),
            child: Text('Add Task', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) {
    int rawDifficulty = taskDifficulty.toInt();
    int remainingDays = computeRemainingDays(taskDeadline);
    double urgencyScore = computeUrgency(remainingDays);
    double importanceScore = normalizeImportance(taskImportance);
    double difficultyScore = normalizeDifficulty(taskDifficulty);

    Task current = Task(
      name: nameController.text,
      deadline: taskDeadline,
      description: descriptionController.text,
      importance: importanceScore,
      difficulty: difficultyScore,
      rawDifficulty: rawDifficulty,
      remainingDays: remainingDays,
      urgency: urgencyScore,
      progress: 0,
    );

    bool tieBrake = checkTieBreak(current, currentSchedule.tasks);
    double priorityScore = computePriority(urgencyScore, importanceScore, difficultyScore, tieBrake);
    bool riskStatus = computeIsRisk(remainingDays, rawDifficulty);

    return Task(
      name: nameController.text,
      deadline: taskDeadline,
      description: descriptionController.text,
      importance: importanceScore,
      difficulty: difficultyScore,
      rawDifficulty: rawDifficulty,
      remainingDays: remainingDays,
      urgency: urgencyScore,
      priority: priorityScore,
      risk: riskStatus,
      progress: 0,
    );
  }
  return null;
}

Widget _buildImportanceOption({
  required String label,
  required bool isSelected,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    ),
  );
}

String _getWeekday(DateTime date) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[date.weekday - 1];
}

String _getMonth(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[date.month - 1];
}

String _formatFullDate(DateTime date) {
  return "${_getWeekday(date)}, ${_getMonth(date)} ${date.day}";
}
