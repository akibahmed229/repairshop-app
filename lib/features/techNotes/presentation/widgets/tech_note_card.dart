import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/edit_tech_note_page.dart';

class TechNoteCard extends StatelessWidget {
  final TechNoteEntities note;
  const TechNoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1, // Keeps the card height consistent
                overflow:
                    TextOverflow.ellipsis, // Adds "..." if text is too long
              ),
            ),
            IconButton(
              // Added padding to separate button from text slightly
              padding: const EdgeInsets.only(left: 8),
              constraints:
                  const BoxConstraints(), // Removes default minimum size constraints
              onPressed: () {
                Navigator.push(context, EditTechNotePage.route(note));
              },
              icon: CircleAvatar(
                backgroundColor: AppPallete.borderColor.withValues(alpha: 0.5),
                child: const Icon(Icons.edit_rounded),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 8,
            ), // Added slight spacing between title and subtitle
            Row(
              children: [
                Icon(
                  note.completed ? Icons.done_rounded : Icons.pending_actions,
                  size: 20, // Adjusted size to fit better
                ),
                const SizedBox(width: 6),
                const Text(
                  "Status: ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  note.completed ? "Completed" : "Opened",
                  style: TextStyle(
                    color: note.completed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 20),
                const SizedBox(width: 6),
                const Text(
                  "Owner: ",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Expanded(
                  // Added Expanded here too just in case username is huge
                  child: Text(
                    "${note.userEmail}",
                    style: const TextStyle(color: Colors.greenAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.event_note, size: 16),
                    const SizedBox(width: 5),
                    Text(formatDateByMMMYYYY(note.createdAt)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.history_toggle_off, size: 16),
                    const SizedBox(width: 5),
                    Text(formatDateByMMMYYYY(note.updatedAt)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
