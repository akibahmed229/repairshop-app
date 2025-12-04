import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart'; // Assuming AppPallete
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';
import 'package:repair_shop/features/users/presentation/widgets/auth_field.dart'; // Assuming AuthField

class NewUserPage extends StatefulWidget {
  // Use a route static method for navigation
  static route() =>
      MaterialPageRoute(builder: (context) => const NewUserPage());

  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final useremailController = TextEditingController();
  final passwordController = TextEditingController();
  final List<String> userRoles = ['Employee', 'Manager', 'Admin'];

  // State variable for the selected role, defaulting to Employee
  String? selectedRole = 'Employee';

  @override
  void initState() {
    super.initState();

    context.read<UserBloc>().add(const GetAllUsersEvent());
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Placeholder function for handling user creation (to be connected to a Bloc)
  void _createUser() {
    if (formKey.currentState!.validate()) {
      final role = selectedRole!.toLowerCase();

      context.read<UserBloc>().add(
        CreateNewUserEvent(
          name: usernameController.text.trim(),
          email: useremailController.text.trim(),
          password: passwordController.text.trim(),
          roles: [role],
        ),
      );

      // You would typically navigate or show a success message here
      // Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New User'), centerTitle: true),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserStateFailure) {
            showSnackBar(context, state.message);
          }

          if (state is CreateNewUserSuccessState) {
            useremailController.clear();
            useremailController.clear();
            passwordController.clear();
            selectedRole = "Employee";

            showSnackBar(context, "User created successfully!");
          }
        },
        builder: (context, state) {
          if (state is UserStateLoading) {
            return const Loader();
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title from the image
                    SizedBox(
                      width: double.infinity,
                      child: const Text(
                        'Add New User',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Username Input Field
                    const Text(
                      'Username: [3-20 letters]',
                      style: TextStyle(color: AppPallete.whiteColor),
                    ),
                    const SizedBox(height: 5),
                    AuthField(
                      controller: usernameController,
                      hintText: 'Enter username',
                    ),
                    const SizedBox(height: 20),

                    // Email Input Field
                    const Text(
                      'Email: [@gmail.com]',
                      style: TextStyle(color: AppPallete.whiteColor),
                    ),
                    const SizedBox(height: 5),
                    AuthField(
                      controller: useremailController,
                      hintText: 'Enter user email',
                    ),
                    const SizedBox(height: 20),

                    // Password Input Field
                    const Text(
                      'Password: [4-12 chars incl. !@#\$%]',
                      style: TextStyle(color: AppPallete.whiteColor),
                    ),
                    const SizedBox(height: 5),
                    AuthField(
                      controller: passwordController,
                      hintText: 'Enter password',
                    ),
                    const SizedBox(height: 20),

                    // Role Selection
                    const Text(
                      'User Role:', // Changed from 'Username' label in image for clarity
                      style: TextStyle(color: AppPallete.whiteColor),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppPallete
                            .backgroundColor, // Use a contrasting background
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppPallete.borderColor),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          dropdownColor: AppPallete.backgroundColor,
                          style: const TextStyle(
                            color: AppPallete.whiteColor,
                            fontSize: 16,
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AppPallete.whiteColor,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRole = newValue;
                            });
                          },
                          items: userRoles.map<DropdownMenuItem<String>>((
                            String role,
                          ) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Sign Up Button (Assumed to be AuthGradientButton)
                    // Note: AuthGradientButton is not defined here, using standard ElevatedButton
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppPallete
                              .gradient1, // Use a gradient color if possible
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'CREATE USER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
