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

final class GetAllCachedUsersSuccessState extends UserState {
  final List<UserEntities> users;
  final String activeUserId; // To know which checkmark to show

  const GetAllCachedUsersSuccessState(this.users, this.activeUserId);
}

final class SwitchUserAccountSuccessState extends UserState {
  final UserEntities user;

  const SwitchUserAccountSuccessState(this.user);
}

final class SignOutCurrentAccountSuccessState extends UserState {
  final UserEntities user;

  const SignOutCurrentAccountSuccessState(this.user);
}

final class SignOutAllAccountSuccessState extends UserState {
  final bool isSuccess;

  const SignOutAllAccountSuccessState(this.isSuccess);
}
