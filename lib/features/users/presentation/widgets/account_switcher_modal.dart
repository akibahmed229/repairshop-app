import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/features/auth/presentation/pages/login_page.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';

class AccountSwitcherModal extends StatefulWidget {
  const AccountSwitcherModal({super.key});

  @override
  State<AccountSwitcherModal> createState() => _AccountSwitcherModalState();
}

class _AccountSwitcherModalState extends State<AccountSwitcherModal> {
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    // Fetch cached users immediately when modal opens
    context.read<UserBloc>().add(const GetAllCachedUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is SwitchUserAccountSuccessState) {
          // IMPORTANT: Update the global user so TechNotePage refreshes data
          context.read<AppWideUserCubit>().updateUser(state.user);
          Navigator.pop(context);

          // refersh ui
          context.read<NotificationBloc>().add(FetchNotificationsEvent());
          context.read<TechNoteBloc>().add(TechNotesGetEvent());
          context.read<TechNoteBloc>().add(TechNotesGetAllUsersEvent());
        }

        if (state is SignOutCurrentAccountSuccessState) {
          // Update the global user to the 'next' available user returned by the bloc
          context.read<AppWideUserCubit>().updateUser(state.user);
          // Refresh the list in the modal
          context.read<UserBloc>().add(const GetAllCachedUsersEvent());
        }

        if (state is SignOutAllAccountSuccessState) {
          // Tell the app there is NO user logged in
          context.read<AppWideUserCubit>().updateUser(null);
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        List<UserEntities> users = [];
        String activeUserId = '';

        if (state is GetAllCachedUsersSuccessState) {
          users = state.users;
          activeUserId = state.activeUserId;
        }

        return Container(
          height:
              MediaQuery.of(context).size.height * 0.5, // Half screen height
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            color: AppPallete.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // --- Header ---
              _buildHeader(context),
              const Divider(color: AppPallete.borderColor, thickness: 0.5),

              // --- User List ---
              Expanded(
                child: state is UserStateLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final isActive = user.id == activeUserId;
                          return _buildUserTile(user, isActive, context);
                        },
                      ),
              ),

              // --- Footer Actions ---
              const Divider(color: AppPallete.borderColor, thickness: 0.5),
              // Only show "Add Account" if not in edit mode to keep UI clean
              if (!_isEditMode)
                _buildFooterOption(
                  icon: Icons.add,
                  label: "Add Account",
                  onTap: () {
                    // Navigate to your Login/Add Account Page
                    context.read<AuthBloc>().add(AuthResetEvent());
                    Navigator.push(context, LoginPage.route());
                  },
                ),

              // Only show "Sign out all" if in edit mode to keep UI clean
              if (_isEditMode)
                _buildFooterOption(
                  icon: Icons.logout,
                  label: "Sign out all accounts",
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthBloc>().add(AuthResetEvent());
                    context.read<UserBloc>().add(SignOutAllUserEvent());
                    Navigator.pushAndRemoveUntil(
                      context,
                      LoginPage.route(),
                      (_) => false,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Accounts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
            child: Text(
              _isEditMode ? "Done" : "Edit",
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(
    UserEntities user,
    bool isActive,
    BuildContext context,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[800],
        backgroundImage: null, // Add user image if available
        child: Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(user.email, style: TextStyle(color: Colors.grey[400])),
      trailing: _isEditMode
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                // LOGIC: Logout single user
                context.read<UserBloc>().add(
                  SignOutCurrentUserEvent(id: user.id),
                );
              },
            )
          : (isActive
                ? const Icon(Icons.check_circle, color: Colors.blue)
                : null),
      onTap: _isEditMode
          ? null // Disable switching while editing
          : () {
              if (!isActive) {
                // LOGIC: Switch Account
                context.read<UserBloc>().add(
                  SwitchUserAccountEvent(id: user.id),
                );
              }
            },
    );
  }

  Widget _buildFooterOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
