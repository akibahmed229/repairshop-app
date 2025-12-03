import 'package:repair_shop/core/secrets/app_secrets.dart';

class SqfliteSchema {
  static final createUserTable =
      '''
  CREATE TABLE ${AppSecrets.userTable}(
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    roles TEXT NOT NULL,
    active INTEGER NOT NULL,
    token TEXT NOT NULL
  );
''';

  static final createTechNotesTable =
      '''
  CREATE TABLE ${AppSecrets.techNotesTable}(
      id TEXT PRIMARY KEY NOT NULL,
      userId TEXT NOT NULL,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      completed INTEGER NOT NULL,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL,
      userName TEXT,
      userEmail TEXT,
      isSynced INTEGER NOT NULL
  );
''';

  static final createTechNoteUsersTable =
      '''
 CREATE TABLE  ${AppSecrets.techNoteUsersTable}(
     id TEXT PRIMARY KEY NOT NULL,
     name TEXT NOT NULL,
     email TEXT NOT NULL,
     roles TEXT NOT NULL,
     active INTEGER NOT NULL,
     createdAt TEXT NOT NULL,
     updatedAt TEXT NOT NULL
 );
''';
}
