import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/task.dart';
import 'widgets/addTaskPrompt.dart';
import 'views/tasks_page.dart';
import 'views/calendar_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: [
            TasksPage(
              schedule: currentSchedule,
              onTaskDeleted: (index) {
                setState(() {
                  currentSchedule.tasks.removeAt(index);
                });
              },
            ),
            CalendarPage(schedule: currentSchedule),
            const Center(child: Text('Matrix View')),
            const Center(child: Text('Settings View')),
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
          child: const Icon(Icons.add, size: 30),
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
                onTap: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
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
                onTap: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
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
                onTap: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
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
                onTap: () {
                  _pageController.animateToPage(
                    3,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
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
