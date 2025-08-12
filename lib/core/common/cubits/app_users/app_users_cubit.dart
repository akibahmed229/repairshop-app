import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';

part 'app_users_state.dart';

class AppUsersCubit extends Cubit<AppUsersState> {
  AppUsersCubit() : super(AppUsersInitial());

  void getAllUsers(List<UserEntities?> users) {
    if (users.isEmpty) {
      emit(AppUsersFailure());
    } else {
      emit(AppUsersSuccessList(users));
    }
  }
}
