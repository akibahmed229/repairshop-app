import 'package:flutter/material.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_dropdown.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_editor.dart';

class AddTechNotePage extends StatefulWidget {
  const AddTechNotePage({super.key});

  @override
  State<AddTechNotePage> createState() => _AddTechNotePageState();
}

class _AddTechNotePageState extends State<AddTechNotePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  String _assignedTo = 'Hemel';

  final List<String> _users = ['Hemel', 'Akib', 'Anika', 'Samir'];

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
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.done_rounded))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "New Note",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title Input
              const Text("Title:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteEditor(
                controller: _titleController,
                hintText: "Enter a short, clear task title",
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Content Input
              const Text("Text:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteEditor(
                controller: _contentController,
                hintText: "Describe the work details, steps, or requirements",
                maxLines: 8,
              ),
              const SizedBox(height: 20),

              // Dropdown
              const Text("ASSIGNED TO:", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 5),
              TechNoteDropdown(assignedTo: _assignedTo, users: _users),
            ],
          ),
        ),
      ),
    );
  }
}
