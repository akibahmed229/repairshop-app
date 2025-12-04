import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/users/domain/usecases/create_new_user.dart';
import 'package:repair_shop/features/users/domain/usecases/delete_user.dart';
import 'package:repair_shop/features/users/domain/usecases/get_all_users.dart';
import 'package:repair_shop/features/users/domain/usecases/update_user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers _getAllUsers;
  final CreateNewUser _createNewUser;
  final UpdateUser _updateUser;
  final DeleteUser _deleteUser;

  UserBloc({
    required GetAllUsers getAllUsers,
    required CreateNewUser createNewUser,
    required UpdateUser updateUser,
    required DeleteUser deleteUser,
  }) : _getAllUsers = getAllUsers,
       _createNewUser = createNewUser,
       _updateUser = updateUser,
       _deleteUser = deleteUser,
       super(UserStateInitial()) {
    on<UserEvent>((event, emit) => emit(UserStateLoading()));
    on<GetAllUsersEvent>(_onGetAllUsersEvent);
    on<CreateNewUserEvent>(_onCreateNewUserEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
    on<DeleteUserEvent>(_onDeleteUserEvent);
  }

  void _onGetAllUsersEvent(
    GetAllUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _getAllUsers(NoParams());

    res.fold(
      (failure) => emit(UserStateFailure(message: failure.message)),
      (users) => emit(GetAllUsersSuccessState(users)),
    );
  }

  void _onCreateNewUserEvent(
    CreateNewUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _createNewUser(
      CreateNewUserParams(
        name: event.name,
        email: event.email,
        password: event.password,
        roles: event.roles,
      ),
    );

    res.fold(
      (failure) => emit(UserStateFailure(message: failure.message)),
      (user) => emit(CreateNewUserSuccessState(user)),
    );
  }

  void _onUpdateUserEvent(
    UpdateUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _updateUser(
      UpdateUserParams(
        id: event.id,
        name: event.name,
        email: event.email,
        password: event.password,
        roles: event.roles,
      ),
    );

    res.fold(
      (failure) => emit(UserStateFailure(message: failure.message)),
      (user) => emit(UpdateUserSuccessState(user)),
    );
  }

  void _onDeleteUserEvent(
    DeleteUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _deleteUser(DeleteUserParams(id: event.id));

    res.fold(
      (failure) => emit(UserStateFailure(message: failure.message)),
      (message) => emit(DeleteUserSuccessState(message)),
    );
  }
}
