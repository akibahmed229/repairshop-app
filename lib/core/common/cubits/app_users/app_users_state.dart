part of 'app_users_cubit.dart';

@immutable
sealed class AppUsersState {
  const AppUsersState();
}

final class AppUsersInitial extends AppUsersState {}

final class AppUsersFailure extends AppUsersState {}

final class AppUsersSuccessList extends AppUsersState {
  final List<UserEntities?> users;
  const AppUsersSuccessList(this.users);
}
