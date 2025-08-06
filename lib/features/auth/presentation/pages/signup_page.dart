import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/widgets/loader.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';
import 'package:repair_shop/core/utils/show_snackbar.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/features/auth/presentation/pages/login_page.dart';
import 'package:repair_shop/features/auth/presentation/widgets/auth_field.dart';
import 'package:repair_shop/features/auth/presentation/widgets/auth_gradient_button.dart';

class SignupPage extends StatefulWidget {
  // Static method to create a route for the SignupPage
  static router() =>
      MaterialPageRoute(builder: (context) => const SignupPage());

  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Global key for the form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Editing Controllers for the fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Center(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                showSnackBar(context, state.message);
              } else if (state is AuthSuccess) {
                showSnackBar(
                  context,
                  'Heloo ${state.user.name} you can now login',
                );

                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Loader();
              }

              return Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign Up.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    AuthField(
                      hintText: 'Username',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 15),
                    AuthField(hintText: 'Email', controller: _emailController),
                    const SizedBox(height: 15),
                    AuthField(
                      hintText: 'Password',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    AuthGradientButton(
                      buttonText: "Sign Up",
                      onPressed: () {
                        // Validate the form fields
                        if (_formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                            AuthSignUpEvent(
                              name: _usernameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, LoginPage.route());
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: ' Sign In',
                              style: const TextStyle(
                                color: AppPallete.gradient2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
