import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/task.dart';
import 'widgets/task_card.dart';
import 'widgets/addTaskPrompt.dart';

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
  Schedule currentSchedule = Schedule(name: 'Schedule 1');

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
                    currentSchedule.name,
                    style: GoogleFonts.poppins(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: currentSchedule.tasks.isEmpty
                  ? const Center(child: Text('No tasks yet. Tap + to add one!'))
                  : ListView.builder(
                itemCount: currentSchedule.tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: currentSchedule.tasks[index],
                    onDelete: () {
                      setState(() {
                        currentSchedule.tasks.removeAt(index);
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
          onPressed: () async {
            Task? newTask = await showAddTaskPrompt(context);
            if (newTask != null) {
              setState(() {
                currentSchedule.tasks.add(newTask);
              });
            }
          },
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
