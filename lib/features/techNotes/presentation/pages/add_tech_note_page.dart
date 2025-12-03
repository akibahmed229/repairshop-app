import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_dropdown.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_editor.dart';

class AddTechNotePage extends StatefulWidget {
  const AddTechNotePage({super.key});

  @override
  State<AddTechNotePage> createState() => _AddTechNotePageState();
}

class _AddTechNotePageState extends State<AddTechNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String? _assignedTo;
  final List<String> _users = [];
  List<UserEntities> _userEntities = [];

  @override
  void initState() {
    super.initState();
    context.read<TechNoteBloc>().add(const TechNotesGetAllUsersEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createNewNote() {
    if (_formKey.currentState?.validate() ?? false) {
      final selectedUser = _userEntities.firstWhere(
        (u) => u.name == _assignedTo,
      );
      context.read<TechNoteBloc>().add(
        TechNoteCreateEvent(
          userId: selectedUser.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _createNewNote,
            icon: CircleAvatar(
              backgroundColor: AppPallete.borderColor.withValues(alpha: 0.5),
              child: const Icon(Icons.done_rounded),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<TechNoteBloc, TechNoteState>(
          listener: (context, state) {
            if (state is TechNoteFailure) {
              showSnackBar(context, state.message);
            }
            if (state is TechNoteCreateSuccess) {
              _titleController.clear();
              _contentController.clear();
              showSnackBar(context, "Note created successfully!");
            }
          },
          builder: (context, state) {
            if (state is TechNoteLoading) {
              return const Loader();
            }

            // If coming from CreateSuccess, keep previous _users list
            if (state is TechNotesGetAllUsersSuccess) {
              _userEntities = state.users;
              _users.clear();
              _users.addAll(_userEntities.map((u) => u.name));
              _assignedTo ??= _users.isNotEmpty ? _users.first : null;
            }

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_add_outlined, size: 36),
                      const SizedBox(width: 10),
                      const Text(
                        "New Note",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text("Title:", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  TechNoteEditor(
                    controller: _titleController,
                    hintText: "Enter a short, clear task title",
                  ),
                  const SizedBox(height: 20),

                  const Text("Text:", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 5),
                  TechNoteEditor(
                    controller: _contentController,
                    hintText: "Describe the work details",
                    minLines: 8,
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "ASSIGNED TO:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  TechNoteDropdown(
                    assignedTo: _assignedTo,
                    users: _users,
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
