import 'dart:math';

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

  Task({
    required this.name,
    required this.deadline,
    required this.description,
    required this.importance,
    required this.difficulty,
    required this.rawDifficulty,
    required this.remainingDays,
    required this.urgency,
    this.priority = 0,
    this.risk = false,
    this.eisenLabel = '',
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
  current.priority = computePriority(current.urgency, current.importance, current.difficulty, false);

  // IF TASKS ARE LESS THAN 3 NO NEED FOR TIE BREAK
  if (tasks.length < 3) {
    return false;
  }

  // CHECKS ALL TASKS AND FIND A MATCH IN PRIORITY SCORE,
  // THEN IT CHECKS IF ITS IMPORTANCE AND URGENCY ARE THE SAME
  for (Task other in tasks) {
    if (other == current) continue;

    if (current.priority == other.priority) {
      if (other.importance == current.importance &&
          other.urgency == current.urgency) {
        return true;
      }
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
    schedule.tasks[i].eisenLabel = assignEisenLabel(i, listLength);
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
const Map<int, int> riskBuffer = {1: 2, 2: 4, 3: 7, 4: 10, 5: 14};

bool computeIsRisk(int remainingDays, int rawDifficulty) {
  return remainingDays <= riskBuffer[rawDifficulty]!; // IF THE REMAINING DAYS IS LESS THAN BUFFER,ITS RISKY
  // E.G: REMAINING DAYS = 5, <= (RAWDIFFICULTY = 3 so RISKBUFFER = 7 days)
  // SINCE 5 <= 7, IT HAS ENTERED RISK WINDOW
}

// ASSIGN EISENLABEL FOR A TASK
String assignEisenLabel(int index, int listLength) {
  if (listLength <= 3) return 'Do'; // IF THERE ARE ONLY 3 TASKS, THEN ALL ARE DO

  final doCount = (listLength * 0.25).ceil().clamp(1, listLength); // CALCULATES TOP 25% AND MAKE THEM DO
  final schedCount = (listLength * 0.35).ceil().clamp(1, listLength); // CALCULATE THE NEXT 35% AND MAKE THEM SCHEDULE

  if (index < doCount) return 'Do'; // IF INDEX/RANK IS WITHIN TOP 25%, THEY'RE DO
  if (index < doCount + schedCount) return 'Schedule'; // IF INDEX/RANK IS WITHIN THE NEXT TOP 35%, THEY'RE SCHEDULE
  return 'Backlog'; // OTHERWISE, THEY'RE BACKLOG
}

