part of 'user_bloc.dart';

@immutable
sealed class UserState {
  const UserState();
}

final class UserStateInitial extends UserState {
  const UserStateInitial();
}

final class UserStateLoading extends UserState {
  const UserStateLoading();
}

final class UserStateFailure extends UserState {
  final String message;

  const UserStateFailure({required this.message});
}

final class GetAllUsersSuccessState extends UserState {
  final List<UserEntities> users;

  const GetAllUsersSuccessState(this.users);
}

final class CreateNewUserSuccessState extends UserState {
  final UserEntities user;

  const CreateNewUserSuccessState(this.user);
}

final class UpdateUserSuccessState extends UserState {
  final UserEntities user;

  const UpdateUserSuccessState(this.user);
}

final class DeleteUserSuccessState extends UserState {
  final String message;

  const DeleteUserSuccessState(this.message);
}
