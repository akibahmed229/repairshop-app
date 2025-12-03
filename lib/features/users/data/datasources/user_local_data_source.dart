import 'package:sqflite/sqflite.dart';

abstract interface class UserLocalDataSource {}

class UserLocalDataSourceImp implements UserLocalDataSource {
  final Database database;

  const UserLocalDataSourceImp({required this.database});
}
