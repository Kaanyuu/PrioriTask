import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final int index;
  final Function(int) onTaskCompleted;
  final VoidCallback onEdit;
  final bool isExpanded;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.index,
    required this.onTaskCompleted,
    required this.onEdit,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    // Standardize importance styling for reuse in the row
    final isHigh = widget.task.importance >= 0.9;
    final isMid = widget.task.importance >= 0.6;
    final importanceColor = isHigh
        ? const Color(0xFFEF4444)
        : (isMid ? const Color(0xFFF59E0B) : const Color(0xFF10B981));
    final importanceText = isHigh ? 'High' : (isMid ? 'Mid ' : 'Low');

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: widget.isExpanded ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: widget.isExpanded ? Colors.amber : Colors.transparent,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap,
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
                      widget.task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.isExpanded ? Colors.amber[800] : Colors.black87,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // EISENLABEL BADGE
                      if (widget.task.risk) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.yellow,
                          weight: 400.0,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ],
                      if (widget.task.remainingDays < 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            "Overdue",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: getEisenLabelColor(widget.task.eisenLabel),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.task.eisenLabel,
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
                          'assets/writing.svg',
                          width: 18,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.amber,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: widget.onEdit,
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
                    width: 15,
                    height: 15,
                    colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${widget.task.deadline.year}-${widget.task.deadline.month.toString().padLeft(2, '0')}-${widget.task.deadline.day.toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 30),

                  // DIFFICULTY STARS
                  RatingBarIndicator(
                    rating: widget.task.difficulty * 5,
                    itemBuilder: (context, index) => SvgPicture.asset(
                      'assets/star.svg',
                      colorFilter: const ColorFilter.mode(Colors.amber, BlendMode.srcIn),
                    ),
                    itemCount: 5,
                    itemSize: 12.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 20),
                  // ADDITIONAL IMPORTANCE INDICATOR
                  Icon(
                    Icons.priority_high,
                    size: 14,
                    color: importanceColor,
                  ),
                  Text(
                    importanceText,
                    style: TextStyle(
                      fontSize: 11,
                      color: importanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 30),

                  // PROGRESS PERCENTAGE
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator.adaptive(
                      value: widget.task.progress / 100,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                    ),
                  ),
                  Text(
                    " ${widget.task.progress}%",
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 30),
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.task.description.isEmpty
                            ? "No description"
                            : widget.task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.task.description.isEmpty ? Colors.grey : Colors.black87,
                          fontStyle: widget.task.description.isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Progress:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Slider.adaptive(
                          value: widget.task.progress.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 4,
                          label: "${widget.task.progress.round()}%",
                          inactiveColor: Colors.grey.shade300,
                          activeColor: Colors.amber.shade600,
                          onChanged: (value) {
                            setState(() {
                              widget.task.progress = value.round();
                            });
                          },
                          onChangeEnd: (value) async {
                            if (value.round() == 100) {
                              final confirmed = await _confirmComplete(context, widget.task);
                              if (confirmed) {
                                widget.onTaskCompleted(widget.index);
                              } else {
                                setState(() {
                                  widget.task.progress = 75;
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.calendar_today_rounded,
                            iconColor: Colors.blue,
                            label: 'Time Left',
                            value: '${widget.task.remainingDays} Days',
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.warning_amber_rounded,
                            iconColor: Colors.orange,
                            label: 'Risk Status',
                            value: widget.task.risk ? 'Risky' : 'Not Risky',
                            backgroundColor: widget.task.risk ? Colors.red.shade50 : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildMetricCard(
                            icon: Icons.computer_rounded,
                            iconColor: Colors.red,
                            label: 'P-Value',
                            value: widget.task.priority.toStringAsFixed(3),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                crossFadeState: widget.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CONFIRM COMPLETE (DON'T CHANGE)
  bool dontShowAgainComplete = false;
  Future<bool> _confirmComplete(BuildContext context, Task task) async {
    if (dontShowAgainComplete) {
      return true; // skip dialog entirely if user opted out
    }

    bool tempDontShow = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mark as complete?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Complete "${task.name}"?'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: tempDontShow,
                    onChanged: (value) {
                      setDialogState(() {
                        tempDontShow = value ?? false;
                      });
                    },
                  ),
                  const Text("Don't show this again", style: TextStyle(fontSize: 13)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Complete'),
            ),
          ],
        ),
      ),
    );

    if (result == true && tempDontShow) {
      setState(() {
        dontShowAgainComplete = true;
      });
    }

    return result ?? false;
  }
}

// FOR METRIC CARDS ON LAST ROW
Widget _buildMetricCard({
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  required Color backgroundColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200, // Subtle border like your original UI
        width: 1,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
