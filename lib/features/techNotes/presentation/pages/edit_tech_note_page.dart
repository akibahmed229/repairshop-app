import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/tech_note_page.dart';
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

    context.read<TechNoteBloc>().add(TechNotesGetAllUsersEvent());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    final selectedUser = _userEntities.firstWhere((u) => u.name == _assignedTo);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _deleteNote,
            icon: CircleAvatar(
              child: const Icon(
                Icons.close_rounded,
                color: AppPallete.errorColor,
              ),
              backgroundColor: AppPallete.borderColor.withOpacity(0.5),
            ),
          ),
          IconButton(
            onPressed: _updateNote,
            icon: CircleAvatar(
              child: const Icon(
                Icons.done_rounded,
                color: AppPallete.successColor,
              ),
              backgroundColor: AppPallete.borderColor.withOpacity(0.5),
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
            _userEntities = state.users;
            _users
              ..clear()
              ..addAll(state.users.map((user) => user.name));

            // Only set _assignedTo once after users are loaded
            if (_users.isNotEmpty &&
                (_assignedTo.isEmpty || _assignedTo == '')) {
              _assignedTo = _users.firstWhere(
                (u) =>
                    u.toLowerCase() ==
                    (widget.note.userName ?? '').toLowerCase(),
                orElse: () => _users.first,
              );
            }
          }
          if (state is TechNoteUpdateAndDeleteSuccess) {
            showSnackBar(context, state.message);
            Navigator.pushAndRemoveUntil(
              context,
              TechNotePage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is TechNoteLoading) {
            return const Loader();
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
                  const Text("Text:", style: TextStyle(color: Colors.white)),
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
                  TechNoteDropdown(
                    assignedTo: _assignedTo,
                    users: _users,
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value ?? _assignedTo;
                      });
                    },
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
                          Text("${formatDateByMMMYYYY(widget.note.createdAt)}"),
                        ],
                      ),

                      Row(
                        children: [
                          const Icon(Icons.history_toggle_off),
                          SizedBox(width: 6),
                          Text("${formatDateByMMMYYYY(widget.note.updatedAt)}"),
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
