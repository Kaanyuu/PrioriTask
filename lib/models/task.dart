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
  double urgency = 1 / (remainingDays + 1);
  if (remainingDays <= 4) {
    urgency = urgency < 0.200 ? 0.200 : urgency;
  }
  return urgency;
}

double normalizeImportance(double importance) => importance / 3.0;
double normalizeDifficulty(double difficulty) => difficulty / 5.0;

bool checkTieBreak(Task current, List<Task> tasks) {

  // Compute priority FIRST NORMALLY
  //current.priority = computePriority(current.urgency, current.importance, current.difficulty, false);

  // IF TASKS ARE LESS THAN 3 NO NEED FOR TIE BREAK
  if (tasks.length < 3) {
    return false;
  }

  // CHECKS ALL TASKS AND FIND A MATCH IN PRIORITY SCORE,
  // THEN IT CHECKS IF ITS IMPORTANCE AND URGENCY ARE THE SAME
  for (Task other in tasks) {
    if (other == current) continue;
      if (other.importance == current.importance && other.urgency == current.urgency) {
        return true;
      }
    }

  return false;
}

// PRIORITY
double computePriority(double urgency, double importance, double difficulty, bool isTiebreak) {
  if (isTiebreak) {
    return (0.45 * importance) + (0.40 * urgency) - (0.15 * difficulty);
  }
  return (0.45 * importance) + (0.40 * urgency) + (0.15 * difficulty);
}

// RECOMPUTE THE PRIORITY SCORE EVERY CHANGE!
void recomputeAll(Schedule schedule) {
  for (Task task in schedule.tasks) {
    task.remainingDays = computeRemainingDays(task.deadline);
    task.urgency = computeUrgency(task.remainingDays);
    task.risk = computeIsRisk(task.remainingDays, task.rawDifficulty);
  }
  for (Task task in schedule.tasks) {
    bool tiebreak = checkTieBreak(task, schedule.tasks);
    task.priority = computePriority(task.urgency, task.importance, task.difficulty, tiebreak);
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
      double pScore2 = sorted[j].priority;
      double pScore1 = sorted[maxIndex].priority;

      if (pScore2 > pScore1) {
        maxIndex = j;
      } else if (sorted[j].priority == sorted[maxIndex].priority) {
        if (sorted[j].importance > sorted[maxIndex].importance) {
          maxIndex = j;
        } else if (sorted[j].importance == sorted[maxIndex].importance) {
          if (sorted[j].deadline.isBefore(sorted[maxIndex].deadline)) {
            maxIndex = j;
          }
        }
      }
    }
    final temp = sorted[i];
    sorted[i] = sorted[maxIndex];
    sorted[maxIndex] = temp;
  }
  return sorted;
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
    if (band == 'Schedule') return 'Do';
  }

  return band;
}

void loadDefaultTasks(Schedule currentSchedule) {
  if (currentSchedule.tasks.isNotEmpty) return;
  final now = DateTime.now();
  currentSchedule.tasks.addAll([
    Task(
      id: 'sample-1',
      name: 'Opinion Essay - English',
      deadline: now.add(const Duration(days: 5)),
      description: 'Write a 1500-word opinion essay with a clear thesis.',
      importance: normalizeImportance(2),
      difficulty: normalizeDifficulty(2),
      rawDifficulty: 2,
    ),
    Task(
      id: 'sample-2',
      name: 'Thesis Part 1 - Introduction',
      deadline: now.add(const Duration(days: 14)),
      description: 'Draft the introduction chapter and background.',
      importance: normalizeImportance(3),
      difficulty: normalizeDifficulty(4),
      rawDifficulty: 4,
    ),
    Task(
      id: 'sample-3',
      name: 'Reading Assignment - Chapter 3',
      deadline: now.add(const Duration(days: 3)),
      description: 'Read chapter 3 and prepare notes for class.',
      importance: normalizeImportance(1),
      difficulty: normalizeDifficulty(1),
      rawDifficulty: 1,
    ),
  ]);
}

const String difficultyInfo =
    '1★ Assignments — 3 days\n'
    '2★ Short Essays — 5 days\n'
    '3★ Exam Review — 7 days\n'
    '4★ Performance Task — >1 week\n'
    '5★ Project — >2 weeks';
const String importanceInfo =
    'Low — No consequences\n'
    'Medium — Matters, not critical\n'
    'High — Must be done, real consequences';

