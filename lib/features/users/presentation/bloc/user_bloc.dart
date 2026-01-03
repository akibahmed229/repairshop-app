import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/users/domain/usecases/create_new_user.dart';
import 'package:repair_shop/features/users/domain/usecases/delete_user.dart';
import 'package:repair_shop/features/users/domain/usecases/get_all_cached_users.dart';
import 'package:repair_shop/features/users/domain/usecases/get_all_users.dart';
import 'package:repair_shop/features/users/domain/usecases/sign_out_all_user.dart';
import 'package:repair_shop/features/users/domain/usecases/sign_out_current_user.dart';
import 'package:repair_shop/features/users/domain/usecases/switch_user_account.dart';
import 'package:repair_shop/features/users/domain/usecases/update_user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsers _getAllUsers;
  final CreateNewUser _createNewUser;
  final UpdateUser _updateUser;
  final DeleteUser _deleteUser;
  final GetAllCachedUsers _getAllCachedUsers;
  final SwitchUserAccount _switchUserAccount;
  final SignOutCurrentUser _signOutCurrentUser;
  final SignOutAllUser _signOutAllUser;

  final SpService _spService;
  final AppWideUserCubit _appWideUserCubit;

  UserBloc({
    required GetAllUsers getAllUsers,
    required CreateNewUser createNewUser,
    required UpdateUser updateUser,
    required DeleteUser deleteUser,
    required GetAllCachedUsers getAllCachedUsers,
    required SwitchUserAccount switchUserAccount,
    required SignOutCurrentUser signOutCurrentUser,
    required SignOutAllUser signOutAllUser,
    required SpService spService,
    required AppWideUserCubit appWideUserCubit,
  }) : _getAllUsers = getAllUsers,
       _createNewUser = createNewUser,
       _updateUser = updateUser,
       _deleteUser = deleteUser,
       _getAllCachedUsers = getAllCachedUsers,
       _switchUserAccount = switchUserAccount,
       _signOutCurrentUser = signOutCurrentUser,
       _signOutAllUser = signOutAllUser,
       _spService = spService,
       _appWideUserCubit = appWideUserCubit,
       super(UserStateInitial()) {
    on<UserEvent>((event, emit) => emit(UserStateLoading()));
    on<GetAllUsersEvent>(_onGetAllUsersEvent);
    on<CreateNewUserEvent>(_onCreateNewUserEvent);
    on<UpdateUserEvent>(_onUpdateUserEvent);
    on<DeleteUserEvent>(_onDeleteUserEvent);
    on<GetAllCachedUsersEvent>(_onGetAllCachedUsersEvent);
    on<SwitchUserAccountEvent>(_onSwitchUserAccountEvent);
    on<SignOutCurrentUserEvent>(_onSignOutCurrentUserEvent);
    on<SignOutAllUserEvent>(_onSignOutAllUserEvent);
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

  void _onGetAllCachedUsersEvent(
    GetAllCachedUsersEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _getAllCachedUsers(NoParams());

    // 2. Get the currently active user (to verify who is logged in)
    final currentUserToken = await _spService.getToken();

    res.fold((failure) => emit(UserStateFailure(message: failure.message)), (
      users,
    ) {
      // Find which user matches the current token
      final activeUser = users.firstWhere(
        (u) => u.token == currentUserToken,
        orElse: () => users.first,
      );

      emit(GetAllCachedUsersSuccessState(users, activeUser.id));
    });
  }

  void _onSwitchUserAccountEvent(
    SwitchUserAccountEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _switchUserAccount(SwitchUserAccountParams(id: event.id));

    res.fold((failure) => emit(UserStateFailure(message: failure.message)), (
      user,
    ) {
      _updateAppWideUserState(user, emit);
      emit(SwitchUserAccountSuccessState(user));
    });
  }

  void _onSignOutCurrentUserEvent(
    SignOutCurrentUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _signOutCurrentUser(
      SignOutCurrentUserParams(id: event.id),
    );

    res.fold((failure) => emit(UserStateFailure(message: failure.message)), (
      user,
    ) {
      _updateAppWideUserState(user, emit);
      emit(SignOutCurrentAccountSuccessState(user));
    });
  }

  void _onSignOutAllUserEvent(
    SignOutAllUserEvent event,
    Emitter<UserState> emit,
  ) async {
    final res = await _signOutAllUser(NoParams());

    res.fold(
      (failure) => emit(UserStateFailure(message: failure.message)),
      (isSuccess) => emit(SignOutAllAccountSuccessState(isSuccess)),
    );
  }

  /// Updates the app-wide user state when authentication succeeds
  void _updateAppWideUserState(UserEntities user, Emitter<UserState> emit) {
    _appWideUserCubit.updateUser(user);
  }
}
