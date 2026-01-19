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
      isSynced INTEGER NOT NULL DEFAULT 0
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

  static final createNotificationsTable =
      '''
  CREATE TABLE ${AppSecrets.notificationsTable}(
      id TEXT PRIMARY KEY NOT NULL,
      userId TEXT NOT NULL,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      type TEXT NOT NULL,
      noteId TEXT NOT NULL,
      isRead INTEGER NOT NULL,
      createdAt TEXT NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0
  );
''';

  static final createMessagesTable =
      '''
  CREATE TABLE ${AppSecrets.messagesTable}(
      id TEXT PRIMARY KEY NOT NULL,
      senderId TEXT NOT NULL,
      receiverId TEXT NOT NULL,
      content TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      isMine INTEGER NOT NULL,
      isSynced INTEGER NOT NULL DEFAULT 0
  );
''';

  static final createConversationsTable =
      '''
  CREATE TABLE ${AppSecrets.conversationTable}(
      id TEXT PRIMARY KEY NOT NULL,
      otherUserId TEXT NOT NULL,
      otherUserName TEXT NOT NULL,
      lastMessage TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      unreadCount INTEGER DEFAULT 0,
      isSynced INTEGER NOT NULL DEFAULT 0
  );
''';
}
