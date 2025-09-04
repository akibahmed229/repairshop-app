import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppSecrets {
  /// Helper to enforce presence of a secret key.
  static String getRequired(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception("Missing required environment variable: $key");
    }
    return value;
  }

  // App secrets
  static final backendUri = getRequired("BACKEND_URL");
  static final usersTable = getRequired("USER_TABLE");
  static final techNotesTable = getRequired("TECH_NOTES_TABLE");
  static final techNoteUsersTable = getRequired("TECH_NOTE_USERS_TABLE");
  static final sqfliteDbName = getRequired("SQFLITE_DB_NAME");
}
