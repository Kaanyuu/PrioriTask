import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/task.dart';
import 'widgets/addTaskPrompt.dart';
import 'views/tasks_page.dart';

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
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Determine which Page to show
    Widget currentView;
    switch (_selectedIndex) {
      case 0:
        currentView = TasksPage(
          schedule: currentSchedule,
          onTaskDeleted: (index) {
            setState(() {
              currentSchedule.tasks.removeAt(index);
            });
          },
        );
        break;
      case 1:
        currentView = const Center(child: Text('Calendar View'));
        break;
      case 2:
        currentView = const Center(child: Text('Matrix View'));
        break;
      case 3:
        currentView = const Center(child: Text('Settings View'));
        break;
      default:
        currentView = const Center(child: Text('Page not found'));
    }

    return Scaffold(
      body: SafeArea(child: currentView),
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
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 0),
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.amber.withValues(alpha: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.list,
                        color: _selectedIndex == 0 ? Colors.amber : Colors.grey,
                      ),
                      Text(
                        'Tasks',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedIndex == 0 ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 1),
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.amber.withValues(alpha: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: _selectedIndex == 1 ? Colors.amber : Colors.grey,
                      ),
                      Text(
                        'Calendar',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedIndex == 1 ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 2),
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.amber.withValues(alpha: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.grid_view,
                        color: _selectedIndex == 2 ? Colors.amber : Colors.grey,
                      ),
                      Text(
                        'Matrix',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedIndex == 2 ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = 3),
                borderRadius: BorderRadius.circular(15),
                splashColor: Colors.amber.withValues(alpha: 0.2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.settings,
                        color: _selectedIndex == 3 ? Colors.amber : Colors.grey,
                      ),
                      Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _selectedIndex == 3 ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
