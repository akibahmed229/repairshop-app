import 'package:flutter/material.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';

class TechNoteCard extends StatelessWidget {
  final TechNoteEntities note;
  const TechNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${note.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.edit_rounded)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Status: ",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${note.completed ? "completed" : "opened"}',
                  style: TextStyle(
                    color: note.completed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Created: ${formatDateByMMMYYYY(note.createdAt)}"),
            Text("Updated: ${formatDateByMMMYYYY(note.updatedAt)}"),
            Text("Owner: ${note.userName}"),
          ],
        ),
      ),
    );
  }
}
