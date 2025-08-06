part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class AuthSignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthSignUpEvent({
    required this.name,
    required this.email,
    required this.password,
  });
}

final class AuthLogInEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLogInEvent({required this.email, required this.password});
}

// Event triggered to check if a user is already logged in
// (e.g., when app starts or resumes)
final class AuthIsUserLoggedInEvent extends AuthEvent {
  const AuthIsUserLoggedInEvent();
}
