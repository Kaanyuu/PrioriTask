import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/task.dart';
import 'services/hive_services.dart';
import 'services/notification_service.dart';
import 'views/calendar_page.dart';
import 'views/tasks_page.dart';
import 'views/settings_page.dart';
import 'widgets/add_task_prompt.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  Hive.registerAdapter(TaskAdapter());
  await HiveService.openTaskBox();
  await NotificationService.init();

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        textTheme: GoogleFonts.robotoTextTheme(),
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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Schedule currentSchedule = Schedule();
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Adds an observer to react whenever the app resumes in background
    WidgetsBinding.instance.addObserver(this);
    
    // Load tasks from Hive
    final savedTasks = HiveService.getTasks();
    if (savedTasks.isEmpty) {
      loadDefaultTasks(currentSchedule);
      // Save default tasks to Hive
      for (var task in currentSchedule.tasks) {
        HiveService.addTask(task);
      }
    } else {
      currentSchedule.tasks = savedTasks;
    }
    
    recomputeAll(currentSchedule);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Disposes Observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Checks if the app is running
    if (state == AppLifecycleState.resumed) {
      setState(() {
        recomputeAll(currentSchedule);
        HiveService.saveAllTasks(currentSchedule.tasks);
      });
    }
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
                  final task = currentSchedule.tasks.removeAt(index);
                  recomputeAll(currentSchedule);
                  HiveService.deleteTask(task.id);
                  HiveService.saveAllTasks(currentSchedule.tasks); // Save updated priorities/labels
                });
              },
              onTaskCompleted: (index) {
                setState(() {
                  final task = currentSchedule.tasks.removeAt(index);
                  recomputeAll(currentSchedule);
                  HiveService.deleteTask(task.id);
                  HiveService.saveAllTasks(currentSchedule.tasks);
                });
            },
              onTaskEdit: (index, updatedTask) {
                setState(() {
                  currentSchedule.tasks[index] = updatedTask;
                  recomputeAll(currentSchedule);
                  HiveService.saveAllTasks(currentSchedule.tasks);
                });
                // saveSchedules([currentSchedule]);
              },
            ),
            CalendarPage(schedule: currentSchedule),
            SettingsPage(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          //Color Gradient of FAB
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFF8B5CF6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.26),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              Task? newTask = await showAddTaskPrompt(context, currentSchedule);
              if (newTask != null) {
                setState(() {
                  currentSchedule.tasks.add(newTask);
                  recomputeAll(currentSchedule);
                  HiveService.saveAllTasks(currentSchedule.tasks);
                });
              }
            },
            customBorder: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),

      //Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
          ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/list-todo.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tasks',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _selectedIndex == 0
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/calendar.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 1
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Calendar',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _selectedIndex == 1
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/settings.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          _selectedIndex == 2
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Settings',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _selectedIndex == 2
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
