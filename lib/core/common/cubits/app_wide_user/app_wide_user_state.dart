part of 'app_wide_user_cubit.dart';

@immutable
sealed class AppWideUserState {
  const AppWideUserState();
}

final class AppWideUserInitial extends AppWideUserState {}

final class AppWideUserLoggedIn extends AppWideUserState {
  final UserEntities user;
  const AppWideUserLoggedIn(this.user);
}
