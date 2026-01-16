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

  // Track the selected email directly
  String? _assignedTo;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _completed = widget.note.completed;

    // 1. Initialize with the existing note's user email
    _assignedTo = widget.note.userEmail;

    // 2. SMART FETCH: Only fetch users if they aren't already in the Bloc state
    // This prevents wiping data or making unnecessary network calls.
    if (context.read<TechNoteBloc>().state.users.isEmpty) {
      context.read<TechNoteBloc>().add(const TechNotesGetAllUsersEvent());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    // 3. Get the latest user list directly from the Bloc State
    final users = context.read<TechNoteBloc>().state.users;

    if (users.isEmpty) {
      showSnackBar(context, "User list not loaded. Cannot update.");
      return;
    }

    // Find the user object based on the selected email
    final selectedUser = users.cast<UserEntities>().firstWhere(
      (u) => u.email == _assignedTo,
      // Fallback to the current note's user ID if not found in list (safety)
      orElse: () => users.firstWhere(
        (u) => u.id == widget.note.userId,
        orElse: () => users.first,
      ),
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
          if (state.status == TechNoteStatus.failure) {
            showSnackBar(context, state.message ?? "An error occurred");
          }

          // 4. Handle Success for Update or Delete
          if (state.status == TechNoteStatus.actionSuccess) {
            showSnackBar(context, state.message ?? "Success");
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          // 5. Access the persisted users list directly
          final users = state.users;

          // Show loader only if we are loading AND have no data
          if (state.status == TechNoteStatus.loading && users.isEmpty) {
            return const Loader();
          }

          // Generate dropdown items from state data
          final List<DropdownMenuItem<String>> userItems = users.map((user) {
            return DropdownMenuItem(
              value: user.email,
              child: Text(user.email, style: const TextStyle(fontSize: 14)),
            );
          }).toList();

          // Safety Check: Ensure the currently selected _assignedTo actually exists in the list.
          // If the user was deleted from the DB, _assignedTo might be invalid for the Dropdown.
          // If invalid, default to the first available user.
          if (users.isNotEmpty &&
              _assignedTo != null &&
              !users.any((u) => u.email == _assignedTo)) {
            _assignedTo = users.first.email;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.edit_note, size: 36),
                      SizedBox(width: 10),
                      Text(
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

                  // Work Complete Checkbox
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

                  // Only show dropdown if we have users, else show a placeholder/loader text
                  users.isEmpty
                      ? const Text(
                          "Loading users...",
                          style: TextStyle(color: Colors.grey),
                        )
                      : MyDropDownMenu(
                          value:
                              _assignedTo ??
                              (users.isNotEmpty ? users.first.email : ''),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _assignedTo = value);
                            }
                          },
                          items: userItems,
                        ),

                  const SizedBox(height: 20),

                  // Created & Updated Dates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note),
                          const SizedBox(width: 6),
                          Text(formatDateByMMMYYYY(widget.note.createdAt)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.history_toggle_off),
                          const SizedBox(width: 6),
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
