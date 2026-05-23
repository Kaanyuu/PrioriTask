class Task {
  String name;
  DateTime deadline;
  String description;
  int importance;  // 1-3
  int difficulty;  // 1-5

  Task({
    required this.name,
    required this.deadline,
    required this.description,
    required this.importance,
    required this.difficulty,
  });
}

class Schedule {
  String name;
  List<Task> tasks;

  Schedule({
    required this.name,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];
}

int computeRemainingDays(DateTime deadline) {
  final today = DateTime.now();
  return deadline.difference(today).inDays;
}

double computeUrgency(int remainingDays) {
  double urgency = 1 / (remainingDays + 1);
  if (remainingDays <= 4) {
    urgency = urgency < 0.200 ? 0.200 : urgency;
  }
  return urgency;
}

double normalizeImportance(int importance) {
  double normImportant;
  return normImportant = importance / 3.0;
}

double normalizeDifficulty(int difficulty) {
  double normDiff;
  return normDiff =  difficulty / 5.0;
}

double computePriority(double urgency, double importance, double difficulty, bool isTiebreak) {
  if (isTiebreak) {
    return (0.45 * importance) + (0.40 * urgency) - (0.15 * difficulty);
  }
  return (0.45 * importance) + (0.40 * urgency) + (0.15 * difficulty);
}

const Map<int, int> riskBuffer = {1: 2, 2: 4, 3: 7, 4: 10, 5: 14};

bool isRisk(int remainingDays, int difficulty) {
  return remainingDays <= riskBuffer[difficulty]!;
}

bool isTiebreak(Task a, Task b, double urgencyA, double urgencyB) {
  return a.importance == b.importance && urgencyA == urgencyB;
}

