import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/format_date.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';
import 'package:repair_shop/features/users/presentation/pages/new_user_page.dart';
import 'package:repair_shop/features/users/presentation/pages/view_user_setting_page.dart';
import 'package:repair_shop/features/users/presentation/widgets/account_switcher_modal.dart';

class UserPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const UserPage());

  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppPallete.transparentColor,
        actions: [
          // User Icon Trigger
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppPallete
                    .transparentColor, // Let the widget handle styling
                isScrollControlled: true, // Allows sheet to grow if needed
                builder: (_) {
                  // IMPORTANT: Provide the existing UserBloc to the sheet
                  return BlocProvider.value(
                    value: context.read<UserBloc>(),
                    child: const AccountSwitcherModal(),
                  );
                },
              );
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircleAvatar(
                // Show current user avatar
                child: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AppWideUserCubit, AppWideUserState>(
        builder: (context, state) {
          if (state is AppWideUserLoggedIn) {
            final user = state.user;
            final isAdmin = user.roles!.contains('admin');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // 1. Gorgeous User Profile Header
                  _buildUserProfile(
                    name: user.name,
                    email: user.email,
                    roles: user.roles!,
                  ),

                  const SizedBox(height: 25),

                  // Date Display
                  Center(
                    child: Text(
                      formatDateByMMMYYYY(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 14,
                        letterSpacing: 1.2,
                        color: AppPallete.greyColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Divider(color: AppPallete.borderColor, thickness: 0.5),
                  const SizedBox(height: 20),

                  // 2. Admin Controls Section
                  if (isAdmin) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 15),
                      child: Text(
                        "ADMIN CONTROLS",
                        style: TextStyle(
                          color: AppPallete.greyColor.withValues(alpha: 0.6),
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      context,
                      title: 'View Users Setting',
                      icon: Icons.settings_outlined,
                      onTap: () {
                        Navigator.of(context).push(ViewUserSettingPage.route());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      context,
                      title: 'Add New User',
                      icon: Icons.person_add_outlined,
                      onTap: () {
                        Navigator.of(context).push(NewUserPage.route());
                      },
                    ),
                  ],
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildUserProfile({
    required String name,
    required String email,
    required List<String> roles,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPallete.borderColor, width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppPallete.borderColor.withValues(alpha: 0.2),
            AppPallete.borderColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Gradient Border
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppPallete.gradient1, AppPallete.gradient2],
                  ),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppPallete.backgroundColor,
                  child: const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: AppPallete.whiteColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // User Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.whiteColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppPallete.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          // Role Chips Row
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: roles.map((role) {
              final bool isSpecial = role.toLowerCase() == 'admin';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSpecial
                        ? AppPallete.gradient2
                        : AppPallete.borderColor,
                    width: 1,
                  ),
                  color: isSpecial
                      ? AppPallete.gradient2.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: isSpecial
                        ? AppPallete.gradient2
                        : AppPallete.whiteColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppPallete.borderColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, color: AppPallete.gradient1, size: 22),
              const SizedBox(width: 18),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppPallete.whiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppPallete.greyColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
