import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/auth/domain/usecases/current_user.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_log_in.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_sign_up.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogIn _userLogIn;
  final CurrentUser _currentUser;

  final AppWideUserCubit _appWideUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogIn userLogIn,
    required CurrentUser currentUser,
    required AppWideUserCubit appWideUserCubit,
  }) : _userSignUp = userSignUp,
       _userLogIn = userLogIn,
       _currentUser = currentUser,
       _appWideUserCubit = appWideUserCubit,
       super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUpEvent>(_onAuthSignUpEvent);
    on<AuthLogInEvent>(_onAuthLogInEvent);
    on<AuthIsUserLoggedInEvent>(_onAuthIsUserLoggedInEvent);
  }

  void _onAuthSignUpEvent(
    AuthSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _userSignUp(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  void _onAuthLogInEvent(AuthLogInEvent event, Emitter<AuthState> emit) async {
    final res = await _userLogIn(
      UserLoginParams(email: event.email, password: event.password),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _updateAppWideUserState(user, emit),
    );
  }

  void _onAuthIsUserLoggedInEvent(
    AuthIsUserLoggedInEvent event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _updateAppWideUserState(user, emit),
    );
  }

  /// Updates the app-wide user state when authentication succeeds
  void _updateAppWideUserState(UserEntities user, Emitter<AuthState> emit) {
    _appWideUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
