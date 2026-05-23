import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final importanceController = TextEditingController();
    final difficultyController = TextEditingController();

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
    //Checks if screen is still mounted, if not, stop code,
    // this stops zombie code
    if (!mounted) return;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;
    //Check if screen is still mounted
    if (!mounted) return;

    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

    
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: importanceController,
              decoration: const InputDecoration(labelText: 'Importance'),
            ),
            TextField(
              controller: difficultyController,
              decoration: const InputDecoration(labelText: 'Difficulty'),
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
    );

    if (confirmed == true) {
      setState(() {
        tasks.add(
          Task(
            name: name,
            deadline: formattedDate,
            description: descriptionController.text,
            importance: importanceController.text,
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
                    color: Colors.amber,
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

