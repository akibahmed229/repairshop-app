import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';
import 'package:repair_shop/features/users/presentation/pages/edit_user_page.dart';
import 'package:repair_shop/features/users/presentation/widgets/table_row_helper.dart';

class ViewUserSettingPage extends StatefulWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => const ViewUserSettingPage());

  const ViewUserSettingPage({super.key});

  @override
  State<ViewUserSettingPage> createState() => _ViewUserSettingPageState();
}

class _ViewUserSettingPageState extends State<ViewUserSettingPage> {
  @override
  void initState() {
    super.initState();
    // DISPATCH EVENT IN INITSTATE
    // This tells the Bloc to fetch the users when the page starts.
    context.read<UserBloc>().add(const GetAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Trigger refresh by dispatching the event again
              context.read<UserBloc>().add(const GetAllUsersEvent());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // Use BlocConsumer or BlocBuilder to handle state and display data
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          // Listen for errors or success messages
          if (state is UserStateFailure) {
            showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          // Display loading screen
          if (state is UserStateLoading) {
            return const Center(child: Loader());
          }

          // Handle the successful fetching state
          if (state is GetAllUsersSuccessState) {
            final users = state.users; // Get the list of users from the state

            if (users.isEmpty) {
              return const Center(
                child: Text(
                  "No users found.",
                  style: TextStyle(color: AppPallete.whiteColor),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(15.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                border: TableBorder.all(color: AppPallete.borderColor),
                columnWidths: const {
                  0: FlexColumnWidth(3), // Username
                  1: FlexColumnWidth(4), // Roles
                  2: FlexColumnWidth(1), // Edit button
                },
                children: [
                  // Header Row
                  buildTableRow(
                    context,
                    username: 'Username',
                    roles: 'Roles',
                    editIcon: 'Edit',
                    isHeader: true,
                  ),
                  // Data Rows
                  ...users.map(
                    (user) => buildTableRow(
                      context,
                      username: user
                          .name, // Use .name or .username based on your UserEntities
                      // Roles is List<String>, join it for display:
                      roles: user.roles!.join(', '),
                      editIcon: 'Icon',
                      onEditTap: () {
                        // TODO: Implement navigation to an 'Edit User' page
                        Navigator.of(context).push(EditUserPage.route(user));
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          // Handle initial or unhandled state (maybe display previous list or a message)
          return const Center(
            child: Text(
              'Press refresh to load users.',
              style: TextStyle(color: AppPallete.whiteColor),
            ),
          );
        },
      ),
    );
  }
}
