import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';

part 'app_wide_user_state.dart';

class AppWideUserCubit extends Cubit<AppWideUserState> {
  AppWideUserCubit() : super(AppWideUserInitial());

  void updateUser(UserEntities? user) {
    if (user == null) {
      emit(AppWideUserInitial());
    } else {
      emit(AppWideUserLoggedIn(user));
    }
  }
}
