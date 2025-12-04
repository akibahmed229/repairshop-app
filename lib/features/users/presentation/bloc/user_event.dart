part of 'user_bloc.dart';

@immutable
sealed class UserEvent {
  const UserEvent();
}

final class GetAllUsersEvent extends UserEvent {
  const GetAllUsersEvent();
}

final class CreateNewUserEvent extends UserEvent {
  final String name;
  final String email;
  final String password;
  final List<String> roles;

  const CreateNewUserEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.roles,
  });
}

final class UpdateUserEvent extends UserEvent {
  final String id;
  final String name;
  final String email;
  final String password;
  final List<String> roles;

  const UpdateUserEvent({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.roles,
  });
}

final class DeleteUserEvent extends UserEvent {
  final String id;

  const DeleteUserEvent({required this.id});
}
