import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path/path.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/common/sqflite/sqflite_schema.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:repair_shop/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:repair_shop/features/auth/data/repository/auth_repository_impl.dart';
import 'package:repair_shop/features/auth/domain/repository/auth_repository.dart';
import 'package:repair_shop/features/auth/domain/usecases/current_user.dart';
import 'package:repair_shop/features/auth/domain/usecases/sync_fcm_device_token.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_log_in.dart';
import 'package:repair_shop/features/auth/domain/usecases/user_sign_up.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_local_source.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:repair_shop/features/chat/data/datasources/chat_socket_service.dart';
import 'package:repair_shop/features/chat/data/repository/chat_repository_impl.dart';
import 'package:repair_shop/features/chat/domain/repository/chat_repository.dart';
import 'package:repair_shop/features/chat/domain/usecases/connect_chat_socket.dart';
import 'package:repair_shop/features/chat/domain/usecases/delete_chat.dart';
import 'package:repair_shop/features/chat/domain/usecases/disconnect_chat_socket.dart';
import 'package:repair_shop/features/chat/domain/usecases/get_chat_history.dart';
import 'package:repair_shop/features/chat/domain/usecases/get_message_stream.dart';
import 'package:repair_shop/features/chat/domain/usecases/search_users.dart';
import 'package:repair_shop/features/chat/domain/usecases/send_message.dart';
import 'package:repair_shop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:repair_shop/features/notifications/data/datasources/notification_local_data_source.dart';
import 'package:repair_shop/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:repair_shop/features/notifications/data/repository/notification_repository_impl.dart';
import 'package:repair_shop/features/notifications/domain/repository/notification_repository.dart';
import 'package:repair_shop/features/notifications/domain/usecases/delete_all_notifications.dart';
import 'package:repair_shop/features/notifications/domain/usecases/get_all_notifications.dart';
import 'package:repair_shop/features/notifications/domain/usecases/mark_notification_as_read.dart';
import 'package:repair_shop/features/notifications/domain/usecases/sync_all_notifications.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/techNotes/data/datasources/tech_note_local_data_source.dart';
import 'package:repair_shop/features/techNotes/data/datasources/tech_note_remote_data_source.dart';
import 'package:repair_shop/features/techNotes/data/repository/tech_note_repository_impl.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/create_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/delete_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_note_users.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_notes.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/sync_all_tech_notes.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/update_tech_note.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/users/data/datasources/user_local_data_source.dart';
import 'package:repair_shop/features/users/data/datasources/user_remote_data_source.dart';
import 'package:repair_shop/features/users/data/repository/user_repository_impl.dart';
import 'package:repair_shop/features/users/domain/repository/user_repository.dart';
import 'package:repair_shop/features/users/domain/usecases/create_new_user.dart';
import 'package:repair_shop/features/users/domain/usecases/delete_user.dart';
import 'package:repair_shop/features/users/domain/usecases/get_all_cached_users.dart';
import 'package:repair_shop/features/users/domain/usecases/get_all_users.dart';
import 'package:repair_shop/features/users/domain/usecases/sign_out_all_user.dart';
import 'package:repair_shop/features/users/domain/usecases/sign_out_current_user.dart';
import 'package:repair_shop/features/users/domain/usecases/switch_user_account.dart';
import 'package:repair_shop/features/users/domain/usecases/update_user.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';
import 'package:sqflite/sqflite.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // shared data like token
  serviceLocator.registerLazySingleton(() => SpService());

  // app wide user info
  serviceLocator.registerLazySingleton(() => AppWideUserCubit());

  // internet connection
  serviceLocator
    ..registerFactory(() => InternetConnection())
    ..registerFactory<ConnectionChecker>(
      () => ConnectionCheckerImpl(serviceLocator()),
    );

  // Local database initiate
  final db = await openDatabase(
    join(await getDatabasesPath(), AppSecrets.sqfliteDbName),
    onCreate: (db, version) async {
      await db.execute(SqfliteSchema.createUserTable);
      await db.execute(SqfliteSchema.createTechNotesTable);
      await db.execute(SqfliteSchema.createTechNoteUsersTable);
      await db.execute(SqfliteSchema.createNotificationsTable);
    },
    version: 1,
  );
  serviceLocator.registerLazySingleton(() => db);

  // message controller for stream of data pulling-pushing from socket.io
  serviceLocator.registerLazySingleton(
    () => StreamController<Map<String, dynamic>>.broadcast(),
  );

  _initAuth();
  _initTechNote();
  _initUsers();
  _initNotifications();
  _initMessages();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl())
    ..registerFactory<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(database: serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        authRemoteDataSource: serviceLocator(),
        authLocalDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
        spService: serviceLocator(),
      ),
    )
    ..registerFactory(() => UserSignUp(authRepository: serviceLocator()))
    ..registerFactory(() => UserLogIn(authRepository: serviceLocator()))
    ..registerFactory(() => CurrentUser(authRepository: serviceLocator()))
    ..registerFactory(
      () => SyncFcmDeviceToken(authRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogIn: serviceLocator(),
        currentUser: serviceLocator(),
        syncFcmDeviceToken: serviceLocator(),
        appWideUserCubit: serviceLocator(),
      ),
    );
}

void _initTechNote() {
  serviceLocator
    ..registerFactory<TechNoteRemoteDataSource>(
      () => TechNoteRemoteDataSourceImpl(),
    )
    ..registerFactory<TechNoteLocalDataSource>(
      () => TechNoteLocalDataSourceImpl(database: serviceLocator()),
    )
    ..registerLazySingleton<TechNoteRepository>(
      () => TechNoteRepositoryImpl(
        techNoteRemoteDataSource: serviceLocator(),
        techNoteLocalDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
        spService: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllTechNotes(techNoteRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SyncAllTechNotes(techNoteRepository: serviceLocator()),
    )
    ..registerFactory(
      () => CreateTechNote(techNoteRepository: serviceLocator()),
    )
    ..registerFactory(
      () => UpdateTechNote(techNoteRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteTechNote(techNoteRepository: serviceLocator()),
    )
    ..registerFactory(
      () => GetAllTechNoteUsers(techNoteRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => TechNoteBloc(
        getAllTechNotes: serviceLocator(),
        syncAllTechNotes: serviceLocator(),
        createTechNote: serviceLocator(),
        updateTechNote: serviceLocator(),
        deleteTechNote: serviceLocator(),
        getAllTechNoteUsers: serviceLocator(),
      ),
    );
}

void _initUsers() {
  serviceLocator
    ..registerFactory<UserRemoteDataSource>(() => UserRemoteDataSourceImpl())
    ..registerFactory<UserLocalDataSource>(
      () => UserLocalDataSourceImp(database: serviceLocator()),
    )
    ..registerFactory<UserRepository>(
      () => UserRepositoryImpl(
        userRemoteDataSource: serviceLocator(),
        userLocalDataSource: serviceLocator(),
        connectionChecker: serviceLocator(),
        spService: serviceLocator(),
      ),
    )
    ..registerFactory(() => GetAllUsers(userRepository: serviceLocator()))
    ..registerFactory(() => CreateNewUser(userRepository: serviceLocator()))
    ..registerFactory(() => UpdateUser(userRepository: serviceLocator()))
    ..registerFactory(() => DeleteUser(userRepository: serviceLocator()))
    ..registerFactory(() => GetAllCachedUsers(userRepository: serviceLocator()))
    ..registerFactory(() => SwitchUserAccount(userRepository: serviceLocator()))
    ..registerFactory(
      () => SignOutCurrentUser(userRepository: serviceLocator()),
    )
    ..registerFactory(() => SignOutAllUser(userRepository: serviceLocator()))
    ..registerLazySingleton(
      () => UserBloc(
        getAllUsers: serviceLocator(),
        createNewUser: serviceLocator(),
        updateUser: serviceLocator(),
        deleteUser: serviceLocator(),
        getAllCachedUsers: serviceLocator(),
        switchUserAccount: serviceLocator(),
        signOutCurrentUser: serviceLocator(),
        signOutAllUser: serviceLocator(),
        spService: serviceLocator(),
        appWideUserCubit: serviceLocator(),
      ),
    );
}

void _initNotifications() {
  serviceLocator
    ..registerFactory<NotificationRemoteDataSource>(
      () => NotificationRemoteDataSourceImpl(),
    )
    ..registerFactory<NotificationLocalDataSource>(
      () => NotificationLocalDataSourceImpl(database: serviceLocator()),
    )
    ..registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(
        spService: serviceLocator(),
        connectionChecker: serviceLocator(),
        notificationRemoteDataSource: serviceLocator(),
        notificationLocalDataSource: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllNotifications(notificationRepository: serviceLocator()),
    )
    ..registerFactory(
      () => MarkNotificationAsRead(notificationRepository: serviceLocator()),
    )
    ..registerFactory(
      () => SyncAllNotifications(notificationRepository: serviceLocator()),
    )
    ..registerFactory(
      () => DeleteAllNotifications(notificationRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => NotificationBloc(
        getAllNotifications: serviceLocator(),
        markNotificationAsRead: serviceLocator(),
        syncAllNotifications: serviceLocator(),
        deleteAllNotifications: serviceLocator(),
      ),
    );
}

void _initMessages() {
  serviceLocator
    ..registerFactory<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl())
    ..registerFactory<ChatLocalSource>(
      () => ChatLocalSourceImpl(database: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ChatSocketService(messageController: serviceLocator()),
    )
    ..registerLazySingleton<ChatRepository>(
      () => ChatRepositoryImpl(
        chatLocalSource: serviceLocator(),
        chatRemoteDataSource: serviceLocator(),
        socketService: serviceLocator(),
        connectionChecker: serviceLocator(),
        spService: serviceLocator(),
      ),
    )
    ..registerFactory(() => ConnectChatSocket(serviceLocator()))
    ..registerFactory(() => DisconnectChatSocket(serviceLocator()))
    ..registerFactory(() => GetMessageStream(serviceLocator()))
    ..registerFactory(() => SendMessage(chatRepository: serviceLocator()))
    ..registerFactory(() => GetChatHistory(chatRepository: serviceLocator()))
    ..registerFactory(() => SearchUsers(chatRepository: serviceLocator()))
    ..registerFactory(() => DeleteChat(chatRepository: serviceLocator()))
    ..registerLazySingleton(
      () => ChatBloc(
        connectChatSocket: serviceLocator(),
        disconnectChatSocket: serviceLocator(),
        getMessageStream: serviceLocator(),
        searchUsers: serviceLocator(),
        getChatHistory: serviceLocator(),
        sendMessage: serviceLocator(),
        deleteChat: serviceLocator(),
      ),
    );
}
