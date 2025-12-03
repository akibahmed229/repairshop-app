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
