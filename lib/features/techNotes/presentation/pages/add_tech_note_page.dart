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
  static route() => MaterialPageRoute(builder: (context) => AddTechNotePage());
  const AddTechNotePage({super.key});

  @override
  State<AddTechNotePage> createState() => _AddTechNotePageState();
}

class _AddTechNotePageState extends State<AddTechNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // We only need local state for the currently selected dropdown value
  String? _assignedTo;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Helper to create note using users list from Bloc state
  void _createNewNote(List<UserEntities> users) {
    if (_formKey.currentState?.validate() ?? false) {
      if (_assignedTo == null) {
        showSnackBar(context, "Please select a user.");
        return;
      }

      // Use .cast<UserEntities>() to fix the type mismatch
      final selectedUser = users.cast<UserEntities>().firstWhere(
        (u) => u.name == _assignedTo,
        orElse: () => users.first,
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
            // Pass the current users list from the bloc state to our function
            onPressed: () =>
                _createNewNote(context.read<TechNoteBloc>().state.users),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: BlocConsumer<TechNoteBloc, TechNoteState>(
          listener: (context, state) {
            if (state.status == TechNoteStatus.failure) {
              showSnackBar(context, state.message ?? "Error");
            }
            if (state.status == TechNoteStatus.actionSuccess) {
              showSnackBar(context, state.message ?? "Success");
              _titleController.clear();
              _contentController.clear();
            }
          },
          builder: (context, state) {
            // 1. Get users directly from state
            final availableUsers = state.users;

            // 2. Initial selection logic (auto-select first user)
            if (_assignedTo == null && availableUsers.isNotEmpty) {
              _assignedTo = availableUsers.first.name;
            }

            // 3. Handle loading only if we have NO users to show
            if (state.status == TechNoteStatus.loading &&
                availableUsers.isEmpty) {
              return const Loader();
            }

            // 4. If loaded but empty
            if (availableUsers.isEmpty &&
                state.status != TechNoteStatus.loading) {
              return const Center(child: Text("No users available"));
            }

            final userItems = availableUsers
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
                  // Title and Description Fields ...
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
                  const Text(
                    "ASSIGNED TO:",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 5),

                  // 5. Dropdown uses the cached users
                  MyDropDownMenu(
                    value: _assignedTo ?? '',
                    onChanged: (value) {
                      setState(() {
                        _assignedTo = value;
                      });
                    },
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
