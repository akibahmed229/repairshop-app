import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/common/widgets/my_drop_down_menu.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
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

  // 1. Make this state depend on the Bloc state, remove the cached list
  String? _assignedTo;

  // 2. Local variables to hold data retrieved from the LAST success state
  List<UserEntities> _availableUsers = [];

  @override
  void initState() {
    super.initState();
    // Fetch users immediately
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _createNewNote() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_assignedTo == null) {
        showSnackBar(context, "Please select a user to assign the note.");
        return;
      }

      // Look up the ID from the current list of available users
      final selectedUser = _availableUsers.firstWhere(
        (u) => u.name == _assignedTo,
        // Fallback for safety, though controlled by dropdown
        orElse: () => throw Exception("Selected user not found."),
      );

      context.read<TechNoteBloc>().add(
        TechNoteCreateEvent(
          userId: selectedUser.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          userName: selectedUser.name,
          userEmail: selectedUser.email,
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
              // Clear fields after success
              _titleController.clear();
              _contentController.clear();
              showSnackBar(context, "Note created successfully!");
              // Optional: Navigator.of(context).pop();

              context.read<TechNoteBloc>().add(TechNotesGetEvent()); // referesh
            }

            // 3. HANDLE SUCCESS STATE IN LISTENER + SETSTATE
            // This is the cleanest way to update StatefulWidget data based on Bloc event success.
            if (state is TechNotesGetAllUsersSuccess) {
              // Check if the data is new before triggering setState
              if (state.users.map((u) => u.id).toSet() !=
                  _availableUsers.map((u) => u.id).toSet()) {
                setState(() {
                  _availableUsers = state.users;
                  // Set default assignedTo only if currently null and we have users
                  if (_assignedTo == null && _availableUsers.isNotEmpty) {
                    _assignedTo = _availableUsers.first.name;
                  }
                });
              }
            }
          },
          builder: (context, state) {
            // 4. Handle Loading and Data Availability Checks
            final bool isLoading = state is TechNoteLoading;
            final bool hasUsers =
                _availableUsers.isNotEmpty && _assignedTo != null;

            if (isLoading && _availableUsers.isEmpty) {
              // Show loader only if we haven't fetched any users yet
              return const Loader();
            }

            if (!hasUsers) {
              // Display this message if fetching is complete but no users were returned
              return const Center(
                child: Text(
                  "No users available to assign notes.",
                  style: TextStyle(color: AppPallete.whiteColor),
                ),
              );
            }

            // 5. Build the Form (We are now guaranteed to have _assignedTo and _availableUsers)
            final List<DropdownMenuItem<String>> userItems = _availableUsers
                .map(
                  (user) => DropdownMenuItem(
                    value: user.name,
                    child: Text(user.email),
                  ),
                )
                .toList();

            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  // ... (Title and Text Editors remain the same)
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

                  const Text(
                    "Description:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  TechNoteEditor(
                    controller: _contentController,
                    hintText: "Describe the work details",
                    minLines: 8,
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Section
                  const Text(
                    "ASSIGNED TO:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  MyDropDownMenu(
                    // Now safely use ! because 'hasUsers' check guarantees non-null
                    value: _assignedTo!,
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value;
                      });
                    },
                    // Pass the list of items built from the successful state
                    items: userItems,
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
