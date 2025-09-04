import 'package:repair_shop/core/secrets/app_secrets.dart';

class SqfliteSchema {
  static final createUserTable =
      '''
  CREATE TABLE ${AppSecrets.usersTable}(
    id TEXT PRIMARY KEY,
    name TEXT,
    email TEXT,
    roles TEXT,
    active INTEGER,
    token TEXT
  );
''';

  static final createTechNotesTable =
      '''
  CREATE TABLE ${AppSecrets.techNotesTable}(
      id TEXT PRIMARY KEY,
      userId TEXT,
      title TEXT,
      content TEXT,
      completed INTEGER,
      createdAt TEXT,
      updatedAt TEXT,
      userName TEXT,
      userEmail TEXT
  );
''';

  static final createTechNoteUsersTable =
      '''
 CREATE TABLE  ${AppSecrets.techNoteUsersTable}(
     id TEXT PRIMARY KEY,
     name TEXT,
     email TEXT,
     roles TEXT,
     active INTEGER,
     createdAt TEXT,
     updatedAt TEXT
 );
''';
}
