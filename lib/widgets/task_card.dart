import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final bool isExpanded;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onDelete,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpanded ? Colors.amber : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isExpanded ? Colors.amber[800] : Colors.black87,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // IMPORTANCE BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: task.importance >= 0.9 
                              ? const Color(0xFFEF4444) // Rose
                              : (task.importance >= 0.6 
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF10B981)), 
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          task.importance >= 0.9 ? 'High' : (task.importance >= 0.6 ? 'Medium' : 'Low'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/trash-2.svg',
                          width: 18,
                          height: 18,
                          colorFilter: const ColorFilter.mode(
                            Colors.redAccent,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // DEADLINE
                  SvgPicture.asset(
                    'assets/calendar.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${task.deadline.year}-${task.deadline.month.toString().padLeft(2, '0')}-${task.deadline.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),

                  // DIFFICULTY STARS
                  RatingBarIndicator(
                    rating: task.difficulty * 5,
                    itemBuilder: (context, index) => SvgPicture.asset(
                      'assets/star.svg',
                      colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                    ),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 12),

                  // ADDITIONAL IMPORTANCE INDICATOR
                  Icon(
                    Icons.priority_high,
                    size: 14,
                    color: task.importance >= 0.9
                        ? const Color(0xFFEF4444)
                        : (task.importance >= 0.6 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                  ),
                  Text(
                    task.importance >= 0.9 ? 'High' : (task.importance >= 0.6 ? 'Med' : 'Low'),
                    style: TextStyle(
                      fontSize: 11,
                      color: task.importance >= 0.9
                          ? const Color(0xFFEF4444)
                          : (task.importance >= 0.6 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // PROGRESS PERCENTAGE (only placeholder yet)
                  const Icon(Icons.incomplete_circle, size: 14, color: Colors.grey),
                  const SizedBox(width: 2),
                  const Text(
                    "0%",
                    style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              // Expanding Animation
              AnimatedCrossFade(
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 20),
                    const Text(
                      "Description:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description.isEmpty ? "No description" : task.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: task.description.isEmpty ? Colors.grey : Colors.black87,
                        fontStyle: task.description.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          "Difficulty: ",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        RatingBarIndicator(
                          rating: task.difficulty * 5,
                          itemBuilder: (context, index) => SvgPicture.asset(
                            'assets/star.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.amber,
                              BlendMode.srcIn,
                            ),
                          ),
                          itemCount: 5,
                          itemSize: 15.0,
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
