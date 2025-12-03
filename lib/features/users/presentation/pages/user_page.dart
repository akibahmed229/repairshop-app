import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/users/presentation/pages/new_user_page.dart';
import 'package:repair_shop/features/users/presentation/pages/view_user_setting_page.dart';

class UserPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const UserPage());

  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming 'Akib' is the current user name retrieved from a global state/cubit
    const String currentUser = 'Akib';

    return Scaffold(
      appBar: AppBar(title: const Text('User Management'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $currentUser',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              formatDateByMMMYYYY(DateTime.now()),
              style: const TextStyle(
                fontSize: 16,
                color: AppPallete.greyColor,
              ), // Assuming you have a subTitleColor
            ),
            const SizedBox(height: 40),

            // -> View User Setting
            _buildMenuItem(
              context,
              title: 'View User Setting',
              icon: Icons.settings,
              onTap: () {
                Navigator.of(context).push(ViewUserSettingPage.route());
              },
            ),
            const Divider(color: AppPallete.borderColor),

            // -> Add New User
            _buildMenuItem(
              context,
              title: 'Add New User',
              icon: Icons.person_add_alt_1,
              onTap: () {
                // Navigating to the page you created previously
                Navigator.of(context).push(NewUserPage.route());
              },
            ),
            const Divider(color: AppPallete.borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Icon(icon, color: AppPallete.whiteColor, size: 24),
            const SizedBox(width: 15),
            Text(
              '-> $title',
              style: const TextStyle(
                fontSize: 18,
                color: AppPallete.whiteColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
