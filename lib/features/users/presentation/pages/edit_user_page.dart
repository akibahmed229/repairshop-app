import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/common/widgets/auth_field.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';

class EditUserPage extends StatefulWidget {
  static route(UserEntities user) =>
      MaterialPageRoute(builder: (context) => EditUserPage(user: user));

  final UserEntities user;

  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  // Form State
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  late bool _isActive;
  late List<String> _selectedRoles;

  // Roles Definition
  final List<String> _allRoles = ['Employee', 'Manager', 'Admin'];

  @override
  void initState() {
    super.initState();
    // 1. Initialize Controller with data from the passed User Entity
    _usernameController = TextEditingController(text: widget.user.name);

    // 2. Password usually stays empty on edit screens (only fill if you want to show it)
    _passwordController = TextEditingController();

    // 3. Initialize Active state from User Entity
    _isActive = widget.user.active!;

    // 4. Create a MUTABLE COPY of the roles list.
    // We use List.from to ensure we don't modify the original entity by reference
    // until we actually hit save.
    _selectedRoles = List<String>.from(widget.user.roles!);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      context.read<UserBloc>().add(
        UpdateUserEvent(
          id: widget.user.id,
          name: _usernameController.text.trim(),
          email: widget.user.email,
          password: _passwordController.text.trim(),
          roles: _selectedRoles,
        ),
      );
    }
  }

  void _onDelete() {
    context.read<UserBloc>().add(DeleteUserEvent(id: widget.user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _onDelete,
            icon: CircleAvatar(
              backgroundColor: AppPallete.borderColor.withValues(alpha: 0.5),
              child: const Icon(
                Icons.close_rounded,
                color: AppPallete.errorColor,
              ),
            ),
          ),
          IconButton(
            onPressed: _onSave,
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
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserStateFailure) {
            showSnackBar(context, state.message);
          }

          if (state is UpdateUserSuccessState) {
            showSnackBar(context, '${state.user.name} updated successfully');
            Navigator.pop(context);
            context.read<UserBloc>().add(const GetAllUsersEvent());
          }

          if (state is DeleteUserSuccessState) {
            showSnackBar(context, state.message);
            Navigator.pop(context);
            context.read<UserBloc>().add(const GetAllUsersEvent());
          }
        },
        builder: (context, state) {
          if (state is UserStateLoading) {
            return const Loader();
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_note, size: 36),
                            SizedBox(width: 10),
                            const Text(
                              "Edit User Setting",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- Username Field ---
                        const Text(
                          "Username: [3-20 letters]",
                          style: TextStyle(color: AppPallete.whiteColor),
                        ),
                        const SizedBox(height: 5),
                        AuthField(
                          controller: _usernameController,
                          hintText: 'Enter username',
                        ),

                        const SizedBox(height: 20),

                        // --- Password Field ---
                        const Text(
                          "Password: [empty = no change] [4-12 chars incl. !@#\$%]",
                          style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AuthField(
                          controller: _passwordController,
                          hintText: "Enter Password",
                          obscureText: true,
                        ),

                        const SizedBox(height: 20),

                        // --- Active Checkbox ---
                        Row(
                          children: [
                            const Text(
                              "ACTIVE:",
                              style: TextStyle(
                                color: AppPallete.whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _isActive,
                                checkColor: AppPallete.whiteColor,
                                side: const BorderSide(
                                  color: AppPallete.whiteColor,
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _isActive = val ?? false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- Assigned Roles ---
                        const Text(
                          "ASSIGNED ROLES:",
                          style: TextStyle(
                            color: AppPallete.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: AppPallete.borderColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: _allRoles.map((role) {
                              // Check against the local mutable list
                              final isSelected = _selectedRoles.contains(
                                role.toLowerCase(),
                              );

                              return CheckboxListTile(
                                title: Text(
                                  role,
                                  style: const TextStyle(
                                    color: AppPallete.whiteColor,
                                  ),
                                ),
                                value: isSelected,
                                activeColor: AppPallete.greyColor,
                                checkColor: Colors.white,
                                dense: true,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedRoles.add(role.toLowerCase());
                                    } else {
                                      _selectedRoles.remove(role.toLowerCase());
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
