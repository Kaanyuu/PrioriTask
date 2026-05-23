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
  // To be abstracted
  void _addTaskPrompt() {
    final nameController = TextEditingController();
    final deadlineController = TextEditingController();
    final descriptionController = TextEditingController();
    final importanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                ),
                TextField(
                  controller: deadlineController,
                  decoration: const InputDecoration(labelText: 'Deadline'),
                ),
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    tasks.add(
                      Task(
                        name: nameController.text,
                        deadline: deadlineController.text,
                        description: descriptionController.text,
                        importance: importanceController.text,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
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
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: tasks[index],
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

