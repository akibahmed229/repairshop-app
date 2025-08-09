import 'package:flutter/material.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_dropdown.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_editor.dart';

class EditTechNotePage extends StatefulWidget {
  static route(TechNoteEntities note) =>
      MaterialPageRoute(builder: (context) => EditTechNotePage(note: note));

  final TechNoteEntities note;

  const EditTechNotePage({super.key, required this.note});

  @override
  State<EditTechNotePage> createState() => _EditTechNotePageState();
}

class _EditTechNotePageState extends State<EditTechNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late String _assignedTo;
  final List<String> _users = ['Hemel', 'Akib', 'Anika', 'Samir'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);

    // Match dropdown value safely
    _assignedTo = _users.firstWhere(
      (user) =>
          user.toLowerCase() == (widget.note.userName ?? '').toLowerCase(),
      orElse: () => _users.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.close_rounded)),
          IconButton(onPressed: () {}, icon: Icon(Icons.done_rounded)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Edit Note",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title Input
              const Text("Title:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteEditor(
                controller: _titleController,
                hintText: "Enter a short, clear task title",
              ),
              const SizedBox(height: 20),

              // Content Input
              const Text("Text:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteEditor(
                controller: _contentController,
                hintText: "Describe the work details, steps, or requirements",
                minLines: 8,
              ),
              const SizedBox(height: 20),

              // Work Complete
              Row(
                children: [
                  const Text(
                    "WORK COMPLETE:",
                    style: TextStyle(color: Colors.white),
                  ),
                  Checkbox(
                    value: widget.note.completed,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dropdown
              const Text("ASSIGNED TO:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteDropdown(assignedTo: _assignedTo, users: _users),
              const SizedBox(height: 20),

              // Created & Updated in a row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      SizedBox(width: 6),
                      Text("${formatDateByMMMYYYY(widget.note.createdAt)}"),
                    ],
                  ),

                  Row(
                    children: [
                      const Icon(Icons.update),
                      SizedBox(width: 6),
                      Text("${formatDateByMMMYYYY(widget.note.updatedAt)}"),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
