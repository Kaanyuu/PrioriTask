import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;
  @HiveField(2)
  DateTime deadline;
  @HiveField(3)
  String description;
  @HiveField(4)
  double importance;  // 1-3
  @HiveField(5)
  double difficulty; // 1-5
  @HiveField(6)
  int rawDifficulty; // For risk calculation
  @HiveField(7)
  int remainingDays;
  @HiveField(8)
  double urgency;
  @HiveField(9)
  double priority;
  @HiveField(10)
  bool risk; // Risk
  @HiveField(11)
  String eisenLabel; // Do, Schedule, Backlog
  @HiveField(12)
  int progress;

  Task({
    required this.id,
    required this.name,
    required this.deadline,
    required this.description,
    required this.importance,
    required this.difficulty,
    required this.rawDifficulty,
    this.remainingDays = 0,
    this.urgency = 0,
    this.priority = 0,
    this.risk = false,
    this.eisenLabel = '',
    this.progress = 0,
  });
}

class Schedule {
  List<Task> tasks;
  Schedule({List<Task>? tasks}) : tasks = tasks ?? [];
}

// --- LOGIC FUNCTIONS ---

int computeRemainingDays(DateTime deadline) {
  return deadline.difference(DateTime.now()).inDays;
}

double computeUrgency(int remainingDays) {
  if (remainingDays <= 0) return 1.0;
  return 1 / (remainingDays + 1);
}

double normalizeImportance(double importance) => importance / 3.0;
double normalizeDifficulty(double difficulty) => difficulty / 5.0;

// PRIORITY
double computePriority(double urgency, double importance, double difficulty) {
  return (0.50 * importance) + (0.45 * urgency) + (0.05 * difficulty);
}

// RECOMPUTE THE PRIORITY SCORE EVERY CHANGE!
void recomputeAll(Schedule schedule) {
  for (Task task in schedule.tasks) {
    task.remainingDays = computeRemainingDays(task.deadline);
    task.urgency = computeUrgency(task.remainingDays);
    task.risk = computeIsRisk(task.remainingDays, task.rawDifficulty);
  }
  for (Task task in schedule.tasks) {
    task.priority = computePriority(task.urgency, task.importance, task.difficulty);
  }
  schedule.tasks = selectionSort(schedule.tasks);
  int listLength = schedule.tasks.length;
  for (int i = 0; i < listLength; i++) {
    schedule.tasks[i].eisenLabel = finalEisenLabel(i, listLength, schedule.tasks[i]);
  }
}

// SORT!
List<Task> selectionSort(List<Task> tasks) {
  List<Task> sorted = List.from(tasks);

  for (int i = 0; i < sorted.length; i++) {
    int maxIndex = i;

    for (int j = i + 1; j < sorted.length; j++) {
      if (compareTasks(sorted[j], sorted[maxIndex]) < 0) {
        maxIndex = j;
      }
    }
    final temp = sorted[i];
    sorted[i] = sorted[maxIndex];
    sorted[maxIndex] = temp;
  }
  return sorted;
}

// COMPARE TASKS TO REORDER
int compareTasks(Task a, Task b) {
  // Normal case — higher score wins
  if (a.priority != b.priority) {
    return b.priority.compareTo(a.priority); // descending
  }

  // Fallback — coincidental score tie, different importance/urgency combo
  if (a.importance != b.importance) {
    return b.importance.compareTo(a.importance); // higher importance wins
  }

  // Final fallback — closer deadline wins
  return a.deadline.compareTo(b.deadline);
}

// RISK
const Map<int, int> riskBuffer = {1: 2, 2: 4, 3: 6, 4: 7, 5: 14};

bool computeIsRisk(int remainingDays, int rawDifficulty) {

  return remainingDays <= riskBuffer[rawDifficulty]!; // IF THE REMAINING DAYS IS LESS THAN BUFFER,ITS RISKY
  // E.G: REMAINING DAYS = 5, <= (RAWDIFFICULTY = 3 so  RISKBUFFER = 7 days)
  // SINCE 5 <= 7, IT HAS ENTERED RISK WINDOW
}

// ASSIGN EISENLABEL FOR A TASK
String assignEisenLabel(int index, int listLength) {
  if (listLength == 1) return 'Do';
  if (listLength <= 3) return index == 0 ? 'Do' : 'Schedule';

  final doCount = (listLength * 0.25).ceil().clamp(1, listLength); // CALCULATES TOP 25% AND MAKE THEM DO
  final schedCount = (listLength * 0.35).ceil().clamp(1, listLength); // CALCULATE THE NEXT 35% AND MAKE THEM SCHEDULE

  if (index < doCount) return 'Do';
  if (index < doCount + schedCount) return 'Schedule';
  return 'Backlog';
}

Color getEisenLabelColor(String band) {
  switch (band) {
    case 'Do': return const Color(0xFFEF4444);
    case 'Schedule': return const Color(0xFF6DB3E9);
    default: return const Color(0xFFADA587);
  }
}

// --- SHARED HELPERS (Date Formatting) ---

String getWeekday(DateTime date) {
  return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
}

String getMonthName(DateTime date) {
  return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1];
}

String formatFullDate(DateTime date) {
  return "${getWeekday(date)}, ${getMonthName(date)} ${date.day}";
}

String finalEisenLabel(int index, int total, Task task) {
  String band = assignEisenLabel(index, total);

  // Mid importance + risk window = promote one band
  if (task.importance == normalizeImportance(2) && task.risk) {
    if (band == 'Backlog') return 'Schedule';
  }

  return band;
}

void loadDefaultTasks(Schedule currentSchedule) {
  if (currentSchedule.tasks.isNotEmpty) return;
  final now = DateTime.now();
  currentSchedule.tasks.addAll([
    // TRUE TIE PAIR — same importance (Mid), same deadline → same urgency
    // Different difficulty. Easier (1★) should rank above harder (4★) ONLY relative to each other.
    Task(
      id: 'sample-1',
      name: 'Tie Test A - Easy Mid',
      deadline: now.add(const Duration(days: 10)),
      description: 'Same importance and deadline as Tie Test B, but easier.',
      importance: normalizeImportance(2),
      difficulty: normalizeDifficulty(1),
      rawDifficulty: 1,
    ),
    Task(
      id: 'sample-2',
      name: 'Tie Test B - Hard Mid',
      deadline: now.add(const Duration(days: 10)),
      description: 'Same importance and deadline as Tie Test A, but harder.',
      importance: normalizeImportance(2),
      difficulty: normalizeDifficulty(4),
      rawDifficulty: 4,
    ),

    // CONTROL TASK — High importance, should outrank both tie tasks above
    // regardless of the tiebreak resolving between A and B.
    Task(
      id: 'sample-3',
      name: 'Control - High Importance Anchor',
      deadline: now.add(const Duration(days: 12)),
      description: 'Should stay above both tie test tasks if the bug is fixed.',
      importance: normalizeImportance(3),
      difficulty: normalizeDifficulty(2),
      rawDifficulty: 2,
    ),

    // CLOSE-SCORE NON-TIE — different importance AND different urgency,
    // but might land close in score. Should NOT trigger tiebreak.
    Task(
      id: 'sample-4',
      name: 'Close Score - Low Imp, Closer Deadline',
      deadline: now.add(const Duration(days: 4)),
      description: 'Different importance and urgency from everything else.',
      importance: normalizeImportance(1),
      difficulty: normalizeDifficulty(3),
      rawDifficulty: 3,
    ),

    // MID + RISK PROMOTION TEST — Mid importance, inside its risk window
    // Should auto-promote one band regardless of raw score.
    Task(
      id: 'sample-5',
      name: 'Mid Risk Promotion Test',
      deadline: now.add(const Duration(days: 2)),
      description: 'Mid importance, difficulty 3 (7-day buffer) — should be risky and promoted.',
      importance: normalizeImportance(2),
      difficulty: normalizeDifficulty(3),
      rawDifficulty: 3,
    ),

    // OVERDUE TEST
    Task(
      id: 'sample-6',
      name: 'Overdue Test Task',
      deadline: now.subtract(const Duration(days: 1)),
      description: 'Deadline already passed — should show as overdue.',
      importance: normalizeImportance(2),
      difficulty: normalizeDifficulty(2),
      rawDifficulty: 2,
    ),

    // FAR + EASY + LOW — should sit comfortably in Backlog
    Task(
      id: 'sample-7',
      name: 'Low Priority Filler',
      deadline: now.add(const Duration(days: 30)),
      description: 'Low importance, easy, far deadline — true backlog material.',
      importance: normalizeImportance(1),
      difficulty: normalizeDifficulty(1),
      rawDifficulty: 1,
    ),

    // FAR + HARD + HIGH — tests effective urgency pull from difficulty
    Task(
      id: 'sample-8',
      name: 'Far But Hard Capstone',
      deadline: now.add(const Duration(days: 20)),
      description: 'High importance, very hard, far deadline.',
      importance: normalizeImportance(3),
      difficulty: normalizeDifficulty(5),
      rawDifficulty: 5,
    ),

    // SECOND TRUE TIE PAIR — different importance tier (High) to verify
    // tiebreak logic generalizes beyond Mid tasks
    Task(
      id: 'sample-9',
      name: 'Tie Test C - Easy High',
      deadline: now.add(const Duration(days: 6)),
      description: 'High importance, same deadline as Tie Test D, easier.',
      importance: normalizeImportance(3),
      difficulty: normalizeDifficulty(2),
      rawDifficulty: 2,
    ),
    Task(
      id: 'sample-10',
      name: 'Tie Test D - Hard High',
      deadline: now.add(const Duration(days: 6)),
      description: 'High importance, same deadline as Tie Test C, harder.',
      importance: normalizeImportance(3),
      difficulty: normalizeDifficulty(5),
      rawDifficulty: 5,
    ),
  ]);
}

const String difficultyInfo =
    '1★ Assignments — 2 days\n'
    '2★ Short Essays — 4 days\n'
    '3★ Exam Review — 6 days\n'
    '4★ Performance Task — >1 week\n'
    '5★ Project — >2 weeks';
const String importanceInfo =
    'Low — No consequences\n'
    'Medium — Matters, not critical\n'
    'High — Must be done, real consequences';

