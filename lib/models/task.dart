

import 'dart:ui';

import 'package:flutter/material.dart';

class Task {
  String name;
  DateTime deadline;
  String description;
  double importance;  // 1-3
  double difficulty; // 1-5
  int rawDifficulty; // For risk calculation
  int remainingDays;
  double urgency;
  double priority;
  bool risk; // Risk
  String eisenLabel; // Do, Schedule, Backlog
  int progress; // progress;

  Task({
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

  Schedule({
    List<Task>? tasks,
  }) : tasks = tasks ?? [];
}

// REMAINING DAYS
int computeRemainingDays(DateTime deadline) {
  final today = DateTime.now();
  return deadline.difference(today).inDays;
}

// URGENCY
double computeUrgency(int remainingDays) {
  double urgency = 1 / (remainingDays + 1);
  if (remainingDays <= 4) {
    urgency = urgency < 0.200 ? 0.200 : urgency;
  }
  return urgency;
}

// IMPORTANCE
double normalizeImportance(double importance) {
  double normImportant;
  return normImportant = importance / 3.0;
}

// DIFFICULTY
double normalizeDifficulty(double difficulty) {
  double normDiff;
  return normDiff =  difficulty / 5.0;
}

// TIEBREAK
bool checkTieBreak(Task current, List<Task> tasks) {

  // Compute priority FIRST NORMALLY
  // current.priority = computePriority(current.urgency, current.importance, current.difficulty, false);

  // IF TASKS ARE LESS THAN 3 NO NEED FOR TIE BREAK
  if (tasks.length < 3) {
    return false;
  }

  // CHECKS ALL TASKS AND FIND A MATCH IN PRIORITY SCORE,
  // THEN IT CHECKS IF ITS IMPORTANCE AND URGENCY ARE THE SAME
  for (Task other in tasks) {
    if (other == current) continue;
      if (other.importance == current.importance &&
          other.urgency == current.urgency) {
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
  for(int i = 0; i < listLength; i++) {
    schedule.tasks[i].eisenLabel = finalEisenLable(i, listLength, schedule.tasks[i]);
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
      }
      if (pScore2 == pScore1) {
        if (sorted[j].importance != sorted[maxIndex].importance) {
          if (sorted[j].importance > sorted[maxIndex].importance) {
            maxIndex = j;
          }
        } else {
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
  if (listLength == 1) return 'Do'; // 1 Task, 1 Do

  if (listLength == 2) {
    return index == 0 ? 'Do' : 'Schedule'; // 2 Task, 1 Do, 1 Schedule
  }

  if (listLength == 3) {
    return index == 0 ? 'Do' : 'Schedule'; // 3 Task, 1 Do, 2 Schedule
  }

  final doCount = (listLength * 0.25).ceil().clamp(1, listLength); // CALCULATES TOP 25% AND MAKE THEM DO
  final schedCount = (listLength * 0.35).ceil().clamp(1, listLength); // CALCULATE THE NEXT 35% AND MAKE THEM SCHEDULE

  if (index < doCount) return 'Do'; // IF INDEX/RANK IS WITHIN TOP 25%, THEY'RE DO
  if (index < doCount + schedCount) return 'Schedule'; // IF INDEX/RANK IS WITHIN THE NEXT TOP 35%, THEY'RE SCHEDULE
  return 'Backlog'; // OTHERWISE, THEY'RE BACKLOG
}

Color getEisenLabelColor(String band) {
  switch (band) {
    case 'Do':       return Color(0xFFEF4444);
    case 'Schedule': return Color(0xFF6DB3E9);
    default:         return Color(0xFFADA587);
  }
}

String finalEisenLable(int index, int total, Task task) {
  String band = assignEisenLabel(index, total);

  // Mid importance + risk window = promote one band
  if (task.importance == normalizeImportance(2) && task.risk) {
    if (band == 'Backlog') return 'Schedule';
    if (band == 'Schedule') return 'Do';
  }

  return band;
}

void loadDefaultTasks(Schedule currentSchedule) {
  if (currentSchedule.tasks.isEmpty) {
    final now = DateTime.now();

    currentSchedule.tasks.addAll([
      Task(
        name: 'Opinion Essay - English',
        deadline: now.add(const Duration(days: 5)),
        description: 'Write a 1500-word opinion essay with a clear thesis and supporting arguments.',
        importance: normalizeImportance(2),
        difficulty: normalizeDifficulty(2),
        rawDifficulty: 2,
      ),
      Task(
        name: 'Thesis Part 1 - Introduction',
        deadline: now.add(const Duration(days: 14)),
        description: 'Draft the introduction chapter, including background and problem statement.',
        importance: normalizeImportance(3),
        difficulty: normalizeDifficulty(4),
        rawDifficulty: 4,
      ),
      Task(
        name: 'Reading Assignment - Chapter 3',
        deadline: now.add(const Duration(days: 3)),
        description: 'Read chapter 3 and prepare notes for class discussion.',
        importance: normalizeImportance(1),
        difficulty: normalizeDifficulty(1),
        rawDifficulty: 1,
      ),
    ]);
  }
}

// FOR INFO/TOOL TIP IN ADD TASK PROMPT
const String difficultyInfo =
    'You may use these as reference for choosing difficulty:\n'
    '1★ Assignments — within three days\n'
    '2★ Short Essays — within five days\n'
    '3★ Exam Review — within seven days\n'
    '4★ Performance Task — more than a week\n'
    '5★ Project — more than two weeks';

const String importanceInfo =
    'You may use these as reference for choosing importance:\n'
    'Low — no real consequences if delayed\n'
    'Medium — matters, but not critical\n'
    'High — must be done, real consequences';

