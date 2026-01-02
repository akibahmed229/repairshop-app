import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/edit_tech_note_page.dart';

class TechNoteCard extends StatelessWidget {
  final TechNoteEntities note;
  final bool isGridView;
  const TechNoteCard({super.key, required this.note, required this.isGridView});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: isGridView
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                if (!isGridView)
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
                if (!isGridView)
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
            // --- DYNAMIC DATETIME SECTION ---
            if (isGridView)
              // GRID: Stack them vertically to prevent overflow
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateItem(Icons.event_note, note.createdAt),
                  const SizedBox(height: 4),
                  _buildDateItem(Icons.history_toggle_off, note.updatedAt),
                ],
              )
            else
              // LIST: Keep them side-by-side
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDateItem(Icons.event_note, note.createdAt),
                  _buildDateItem(Icons.history_toggle_off, note.updatedAt),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget to keep the date code clean
  Widget _buildDateItem(IconData icon, DateTime date) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 5),
        Text(formatDateByMMMYYYY(date), style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
