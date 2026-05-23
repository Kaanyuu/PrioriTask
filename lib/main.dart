import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrioriTask',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),
      home: const MyHomePage(title: 'PrioriTask'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Task> tasks = [];

  Future<void> _addTaskPrompt() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    // 1. Ask for Name
    String? name = await showDialog<String>(
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

    if (name == null || name.isEmpty) return;

    // 2. Ask for Deadline (Calendar)
    DateTime? pickedDate = await showDatePicker(
      context: context,
      helpText: 'Select deadline',
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;
    String formattedDate =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

    // 3. Ask for Description, Difficulty, and Importance
    String selectedImportance = 'Low'; // Dialog state variable
    double selectedDifficulty = 1; // Difficulty state variable

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder( // Allows setState inside dialog
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Final Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),

              // DIFFICULTY LABEL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Difficulty',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // STARS FOR DIFFICULTY
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
                  size: 20.0,
                ),
                onRatingUpdate: (rating) {
                  setDialogState(() {
                    selectedDifficulty = rating;
                  });
                },
              ),

              // Importance LABEL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Importance',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Horizontal Low / Medium / High toggle
              ToggleButtons(
                isSelected: [
                  selectedImportance == 'Low',
                  selectedImportance == 'Medium',
                  selectedImportance == 'High',
                ],
                onPressed: (int index) {
                  setDialogState(() {
                    selectedImportance = ['Low', 'Medium', 'High'][index];
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
      setState(() {
        tasks.add(
          Task(
            name: name,
            deadline: formattedDate,
            description: descriptionController.text,
            difficulty: selectedDifficulty.toString(),
            importance: selectedImportance,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PrioriTask header
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
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

            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                child: Text('No tasks yet. Tap + to add one!'),
              )
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: tasks[index],
                    onDelete: () {
                      setState(() {
                        tasks.removeAt(index);
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskPrompt,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}