import 'package:flutter/material.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/edit_tech_note_page.dart';

class TechNoteCard extends StatelessWidget {
  final TechNoteEntities note;
  final List<UserEntities> users;
  final bool isGridView;

  const TechNoteCard({
    super.key,
    required this.note,
    required this.users,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    // Define status colors
    final statusColor = note.completed
        ? Colors.greenAccent
        : Colors.orangeAccent;
    final statusIcon = note.completed ? Icons.check_circle : Icons.pending;
    final statusText = note.completed ? "Completed" : "Open";

    return Card(
      margin: isGridView
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0, // Minimalist flat look
      color: AppPallete.borderColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppPallete.borderColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, EditTechNotePage.route(note, users));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER: TITLE & EDIT ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Minimalist Edit Button
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      EditTechNotePage.route(note, users),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      size: 24,
                      color: AppPallete.whiteColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --- BODY: STATUS & OWNER ---
              // --- BODY: STATUS & OWNER ---
              Column(
                spacing: 8, // Slightly reduced spacing for better fit
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Pill
                  Row(
                    children: [
                      if (!isGridView) const Text("Status: "),
                      const SizedBox(width: 4),
                      _buildPill(statusColor, statusText, statusIcon),
                    ],
                  ),

                  // Owner Info
                  Row(
                    children: [
                      if (!isGridView) const Text("Owner: "),
                      const SizedBox(width: 4),
                      Flexible(
                        fit: FlexFit
                            .loose, // This tells the pill: "Take only the space you need"
                        child: _buildPill(
                          Colors
                              .blueAccent, // Highlight Color: Professional Blue
                          note.userEmail!,
                          Icons.alternate_email_rounded,
                          isEmail: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Only use Spacer in GridView because Grid tiles have fixed height.
              // In ListView, the card wraps content, so Spacer() causes a crash.
              if (isGridView) const Spacer() else const SizedBox(height: 20),
              const Divider(height: 1, thickness: 0.2),
              const SizedBox(height: 8),

              // --- FOOTER: DATES ---
              // Logic: In Grid, space is tight, keep minimal. In List, spread out.
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  letterSpacing: 0.3,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDateItem(
                      Icons.calendar_today_rounded,
                      note.createdAt,
                    ),
                    if (!isGridView) ...[
                      // Only show "Updated" label in List view if you want,
                      // or show the icon logic below for both:
                      _buildDateItem(
                        Icons.update_rounded,
                        note.updatedAt,
                        isRight: true,
                      ),
                    ] else
                      // In Grid, just show the update icon to save space
                      Icon(
                        Icons.update_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateItem(IconData icon, DateTime date, {bool isRight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isRight) ...[
          Text(formatDateByMMMYYYY(date)),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: Colors.grey[600]),
        ] else ...[
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(formatDateByMMMYYYY(date)),
        ],
      ],
    );
  }

  Widget _buildPill(
    Color color,
    String text,
    IconData icon, {
    bool isEmail = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Using a slightly stronger background for the email highlight
        color: color.withValues(alpha: isEmail ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            // Added Flexible here to prevent the internal Row from overflowing
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isEmail ? FontWeight.w600 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
