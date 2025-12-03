import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class UserData {
  final String username;
  final String roles;
  UserData({required this.username, required this.roles});
}

class ViewUserSettingPage extends StatelessWidget {
  static route() =>
      MaterialPageRoute(builder: (context) => ViewUserSettingPage());

  ViewUserSettingPage({super.key});

  final List<UserData> users = [
    UserData(username: 'Hemel', roles: 'Employee, Manager'),
    UserData(username: 'yeanur', roles: 'Manager'),
    UserData(username: 'Ishmam', roles: 'Employee'),
    UserData(username: 'Akib', roles: 'Admin'),
    UserData(username: 'Sakib', roles: 'Employee, Manager'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement refresh logic (fetch users from server/database)
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            _buildTableRow(
              context,
              username: 'Username',
              roles: 'Roles',
              editIcon: 'Edit',
              isHeader: true,
            ),
            // Data Rows
            ...users.map(
              (user) => _buildTableRow(
                context,
                username: user.username,
                roles: user.roles,
                editIcon: 'Icon', // Placeholder value
                onEditTap: () {
                  // TODO: Implement navigation to an 'Edit User' page
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    BuildContext context, {
    required String username,
    required String roles,
    required String editIcon,
    VoidCallback? onEditTap,
    bool isHeader = false,
  }) {
    final textStyle = TextStyle(
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: AppPallete.whiteColor,
    );
    final padding = EdgeInsets.symmetric(
      vertical: isHeader ? 12 : 8,
      horizontal: 8,
    );

    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? AppPallete.borderColor.withValues(alpha: 0.5) : null,
      ),
      children: [
        Padding(
          padding: padding,
          child: Text(username, style: textStyle),
        ),
        Padding(
          padding: padding,
          child: Text(roles, style: textStyle),
        ),
        Center(
          child: isHeader
              ? Padding(
                  padding: padding,
                  child: Text(editIcon, style: textStyle),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: AppPallete.whiteColor,
                  ),
                  onPressed: onEditTap,
                ),
        ),
      ],
    );
  }
}
