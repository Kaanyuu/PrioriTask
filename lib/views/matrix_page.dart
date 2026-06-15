import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class MatrixPage extends StatelessWidget {
  final Schedule schedule;

  const MatrixPage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _quadrantBox('Do', Colors.red.shade800)),
                Expanded(child: _quadrantBox('Schedule', Colors.blue.shade800)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _quadrantBox('Backlog', Colors.grey.shade800)),
                Expanded(child: _quadrantBox('Completed', Colors.green.shade800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // define it inside the class
  Widget _quadrantBox(String eisenLabel, Color color) {
    final bandTasks = schedule.tasks.where((task) => task.eisenLabel == eisenLabel).toList();

    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eisenLabel,
            style: GoogleFonts.roboto(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: bandTasks.isEmpty
                ? Center(
              child: Text(
                'No tasks',
                style: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            )
                : ListView.builder(
              itemCount: bandTasks.length,
              itemBuilder: (context, index) {
                return Text(
                  '${bandTasks[index].name}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
