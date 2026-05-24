import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/task.dart';
import '../main.dart';

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
      title: const Text('Task Name'),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: const InputDecoration(hintText: "Task Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              Navigator.pop(context, nameController.text);
            }
          },
          child: const Text('Next'),
        ),
      ],
    ),
  );

  if (taskName == null || taskName.isEmpty) return null;
  // Checks if screen is still mounted to stop zombie code
  if (!context.mounted) return null;

  // Select Date Section
  DateTime? taskDeadline = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
    confirmText: 'Next',
    helpText: 'Select Deadline',
  );

  if (taskDeadline == null) return null;
  //Checks if screen is still mounted
  if (!context.mounted) return null;

  // Description, Difficulty and Importance Section
  String selectedImportance = 'Low';
  double selectedDifficulty = 1;

  bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Final Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // DESCRIPTION
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 16),

            // DIFFICULTY
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Difficulty',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Roboto'),
              ),
            ),
            const SizedBox(height: 6),
            RatingBar.builder(
              initialRating: selectedDifficulty,
              minRating: 1,
              maxRating: 5,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setDialogState(() {
                  selectedDifficulty = rating;
                  taskDifficulty = selectedDifficulty;
                });
              },
            ),

            // IMPORTANCE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Importance',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Roboto'),
              ),
            ),
            const SizedBox(height: 6),
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
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: selectedImportance == 'High'
                  ? Colors.red
                  : selectedImportance == 'Medium'
                  ? Colors.orange
                  : Colors.green,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Low'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Medium'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('High'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add Task'),
          ),
        ],
      ),
    ),
  );

  if (confirmed == true) {

    // GET THE REMAINING ATTRIBUTES
    int remainingDays = computeRemainingDays(taskDeadline);
    double urgencyScore = computeUrgency(remainingDays);
    double importanceScore = normalizeImportance(taskImportance);
    double difficultyScore = normalizeDifficulty(taskDifficulty);

    // INITIALIZE CURRENT TASK FIRST TO CHECK FOR TIEBREAK
    Task current = Task(
      name: nameController.text,
      deadline: taskDeadline,
      description: descriptionController.text,
      importance: importanceScore,
      difficulty: difficultyScore,
      remainingDays: remainingDays,
      urgency: urgencyScore,
    );

    // CHECK TIEBREAK, THEN COMPUTE PSCORE
    bool tieBrake = checkTieBreak(current, currentSchedule.tasks);
    double priorityScore = computePriority(urgencyScore, importanceScore, difficultyScore, tieBrake);

    // RETURN COMPLETE TASK
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
