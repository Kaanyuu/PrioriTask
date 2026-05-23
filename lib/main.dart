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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;
    String formattedDate = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";

    // 3. Ask for Description and Importance
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

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      //To be changed
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskPrompt,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

