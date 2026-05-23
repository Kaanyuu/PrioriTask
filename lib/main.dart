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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrioriTask',
      //Theme of the application
      theme: ThemeData(
        //Color scheme of the app
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

  //Add task prompt
  Future<void> _addTaskPrompt() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    int taskDifficulty = 0;
    int taskImportance = 0;

    // 1. Ask for name
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

    if (taskName == null || taskName.isEmpty) return;
    //Checks if screen is still mounted, if not, stop code,
    // this stops zombie code
    if (!mounted) return;

    // 2. Ask for deadline
    DateTime? taskDeadline = await showDatePicker(
      context: context,
      helpText: 'Select deadline',
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (taskDeadline == null) return;
    //Check if screen is still mounted
    if (!mounted) return;

    // 3. Ask for Description, Difficulty, Importance
    String selectedImportance = 'Low'; // Dialog state | Initilization
    double selectedDifficulty = 1; // Dialog state | Initilization

    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder( // ✅ Allows setState inside dialog
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
                    taskDifficulty = selectedDifficulty.toInt();
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
      setState(() {
        tasks.add(
          Task(
            name: nameController.text,
            deadline: taskDeadline,
            description: descriptionController.text,
            importance: taskImportance,
            difficulty: taskDifficulty,
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
            // PrioriTask shape
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
                    'Schedule 1',
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
                  ? const Center(child: Text('No tasks yet. Tap + to add one!'))
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 60,
        width: 60,
        child: FloatingActionButton(
          onPressed: _addTaskPrompt,
          tooltip: 'Add Task',
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30), // Bigger icon to match
        ),
      ),

      //Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {},
              tooltip: 'Tasks',
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () {},
              tooltip: 'Calendar',
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.grid_view),
              onPressed: () {},
              tooltip: 'Matrix',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
              tooltip: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
