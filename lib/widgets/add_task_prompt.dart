import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Task Name',
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: TextField(
          controller: nameController,
          autofocus: true,
          style: GoogleFonts.roboto(fontSize: 14),
          decoration: InputDecoration(
            hintText: "What needs to be done?",
            hintStyle: GoogleFonts.roboto(fontSize: 14, color: Colors.grey),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.amber),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.amber, width: 2),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              Navigator.pop(context, nameController.text);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: Text('Next', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );

  if (taskName == null || taskName.isEmpty) return null;
  if (!context.mounted) return null;

  // Select Date Section
  DateTime? taskDeadline = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
    confirmText: 'Next',
    helpText: 'Select Deadline',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.amber,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
          textTheme: GoogleFonts.robotoTextTheme(),
        ),
        child: child!,
      );
    },
  );

  if (taskDeadline == null) return null;
  if (!context.mounted) return null;

  // Description, Difficulty and Importance Section
  String selectedImportance = 'Low';
  double selectedDifficulty = 1;

  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Final Details',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: SingleChildScrollView(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
              const SizedBox(height: 8),
              RatingBar.builder(
                initialRating: selectedDifficulty,
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
                    selectedDifficulty = rating;
                    taskDifficulty = selectedDifficulty;
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
              ToggleButtons(
                isSelected: [
                  selectedImportance == 'Low',
                  selectedImportance == 'Medium',
                  selectedImportance == 'High',
                ],
                onPressed: (int index) {
                  setDialogState(() {
                    selectedImportance = ['Low', 'Medium', 'High'][index];
                    taskImportance = index + 1;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: selectedImportance == 'High'
                    ? Colors.redAccent
                    : selectedImportance == 'Medium'
                    ? Colors.orangeAccent
                    : Colors.greenAccent[700],
                constraints: const BoxConstraints(minHeight: 40, minWidth: 70),
                children: [
                  Text('Low', style: GoogleFonts.roboto(fontSize: 12)),
                  Text('Medium', style: GoogleFonts.roboto(fontSize: 12)),
                  Text('High', style: GoogleFonts.roboto(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.roboto(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text('Add Task', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) {
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
      remainingDays: remainingDays,
      urgency: urgencyScore,
    );

    bool tieBrake = checkTieBreak(current, currentSchedule.tasks);
    double priorityScore = computePriority(urgencyScore, importanceScore, difficultyScore, tieBrake);

    return Task(
      name: nameController.text,
      deadline: taskDeadline,
      description: descriptionController.text,
      importance: importanceScore,
      difficulty: difficultyScore,
      remainingDays: remainingDays,
      urgency: urgencyScore,
      priority: priorityScore,
    );
  }
  return null;
}
