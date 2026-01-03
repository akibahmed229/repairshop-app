import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/common/widgets/my_drop_down_menu.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/widgets/tech_note_editor.dart';

class EditTechNotePage extends StatefulWidget {
  static route(TechNoteEntities note, List<UserEntities> users) =>
      MaterialPageRoute(
        builder: (context) => EditTechNotePage(note: note, users: users),
      );

  final TechNoteEntities note;
  final List<UserEntities> users;

  const EditTechNotePage({super.key, required this.note, required this.users});

  @override
  State<EditTechNotePage> createState() => _EditTechNotePageState();
}

class _EditTechNotePageState extends State<EditTechNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late String _assignedTo = '';
  late bool _completed;
  final List<String> _users = [];
  List<UserEntities> _userEntities = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _completed = widget.note.completed;

    // FIX: Populate the local lists immediately from the passed widget data
    _populateUsers(widget.users);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final selectedUser = _userEntities.firstWhere(
      (u) => u.email == _assignedTo,
    );

    context.read<TechNoteBloc>().add(
      TechNoteUpdateEvent(
        id: widget.note.id,
        userId: selectedUser.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        completed: _completed,
      ),
    );
  }

  void _deleteNote() {
    context.read<TechNoteBloc>().add(TechNoteDeleteEvent(id: widget.note.id));
  }

  void _populateUsers(List<UserEntities> users) {
    setState(() {
      _userEntities = users;
      _users.clear();
      _users.addAll(users.map((user) => user.email));

      // Match the current note's userEmail to the list, or default to first
      if (_users.isNotEmpty) {
        _assignedTo = _users.contains(widget.note.userEmail)
            ? widget.note.userEmail!
            : _users.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _deleteNote,
            icon: CircleAvatar(
              backgroundColor: AppPallete.borderColor.withValues(alpha: 0.5),
              child: const Icon(
                Icons.close_rounded,
                color: AppPallete.errorColor,
              ),
            ),
          ),
          IconButton(
            onPressed: _updateNote,
            icon: CircleAvatar(
              backgroundColor: AppPallete.borderColor.withValues(alpha: 0.5),
              child: const Icon(
                Icons.done_rounded,
                color: AppPallete.successColor,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<TechNoteBloc, TechNoteState>(
        listener: (context, state) {
          if (state is TechNoteFailure) {
            showSnackBar(context, state.message);
          }

          if (state is TechNotesGetAllUsersSuccess) {
            _populateUsers(state.users);
          }

          if (state is TechNoteUpdateAndDeleteSuccess) {
            showSnackBar(context, state.message);
            Navigator.pop(context);
            context.read<TechNoteBloc>().add(TechNotesGetEvent());
          }
        },
        builder: (context, state) {
          if (state is TechNoteLoading) {
            return const Loader();
          }

          if (_users.isEmpty && state is! TechNoteLoading) {
            return const Center(child: Text("Loading users..."));
          }

          return Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_note, size: 36),
                      SizedBox(width: 10),
                      const Text(
                        "Edit Note",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  const Text(
                    "Description:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  TechNoteEditor(
                    controller: _contentController,
                    hintText:
                        "Describe the work details, steps, or requirements",
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
                        value: _completed,
                        onChanged: (value) {
                          setState(() {
                            _completed = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dropdown
                  const Text(
                    "ASSIGNED TO:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  MyDropDownMenu(
                    // Ensure value is never empty if items exist
                    value: _assignedTo.isEmpty && _users.isNotEmpty
                        ? _users.first
                        : _assignedTo,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _assignedTo = value);
                      }
                    },
                    items: _users.map((email) {
                      return DropdownMenuItem(
                        value: email,
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Created & Updated in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note),
                          SizedBox(width: 6),
                          Text(formatDateByMMMYYYY(widget.note.createdAt)),
                        ],
                      ),

                      Row(
                        children: [
                          const Icon(Icons.history_toggle_off),
                          SizedBox(width: 6),
                          Text(formatDateByMMMYYYY(widget.note.updatedAt)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
