import 'package:repair_shop/core/common/models/user_model.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract interface class TechNoteLocalDataSource {
  Future<TechNoteModel> createTechNote({
    required String userId,
    required String title,
    required String content,
  });

  Future<String> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  });

  Future<String> deleteTechNote({required String id});

  Future<List<TechNoteModel>> getUnSyncedTechNotes();

  Future<void> markAllTechNotesAsSynced();

  Future<void> cacheTechNotes(List<TechNoteModel> notes);
  Future<void> cacheTechNoteUsers(List<UserModel> users);

  Future<List<TechNoteModel>?> getCachedTechNotes();
  Future<List<UserModel>?> getCachedTechNoteUsers();

  Future<void> clearTechNotes();
  Future<void> clearTechNoteUsers();
}

class TechNoteLocalDataSourceImpl implements TechNoteLocalDataSource {
  final Database database;
  const TechNoteLocalDataSourceImpl({required this.database});

  @override
  Future<TechNoteModel> createTechNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      final String noteId = Uuid().v7();

      await database.insert(AppSecrets.techNotesTable, {
        "id": noteId,
        "userId": userId,
        "title": title,
        "content": content,
        "completed": 0,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
        "isSynced": 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final List<Map<String, dynamic>> notes = await database.query(
        AppSecrets.techNotesTable,
        where: "id = ?",
        whereArgs: [noteId],
      );

      if (notes.isNotEmpty) {
        return TechNoteModel.fromJson(notes.first);
      } else {
        throw ServerExecptions(
          "Failed to create note: Query after insert failed",
        );
      }
    } catch (e) {
      throw ServerExecptions("Failed to create note: ${e.toString()}");
    }
  }

  @override
  Future<String> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  }) async {
    try {
      final List<Map<String, dynamic>> isNoteExists = await database.query(
        AppSecrets.techNotesTable,
        where: "id = ?",
        whereArgs: [id],
      );

      if (isNoteExists.isEmpty) {
        throw ServerExecptions("Failed to update note, something went wrong!!");
      }

      await database.update(
        AppSecrets.techNotesTable,
        {
          "userId": userId,
          "title": title,
          "content": content,
          "completed": completed ? 1 : 0,
          "updatedAt": DateTime.now().toIso8601String(),
          "isSynced": 0,
        },
        where: "id = ?",
        whereArgs: [id],
      );

      return "$title updated";
    } catch (e) {
      throw ServerExecptions("Failed to update note: ${e.toString()}");
    }
  }

  @override
  Future<String> deleteTechNote({required String id}) async {
    try {
      await database.delete(
        AppSecrets.techNotesTable,
        where: "id = ?",
        whereArgs: [id],
      );

      return "Note with ID $id deleted";
    } catch (e) {
      throw ServerExecptions("Failed to delete note: ${e.toString()}");
    }
  }

  @override
  Future<List<TechNoteModel>> getUnSyncedTechNotes() async {
    try {
      final result = await database.query(
        AppSecrets.techNotesTable,
        where: 'isSynced = ?',
        whereArgs: [0],
      );

      if (result.isNotEmpty) {
        List<TechNoteModel> tasks = [];
        for (final note in result) {
          tasks.add(TechNoteModel.fromJson(note));
        }
        return tasks;
      }

      return [];
    } catch (e) {
      throw ServerExecptions("Failed to get unsynced note: ${e.toString()}");
    }
  }

  @override
  Future<void> markAllTechNotesAsSynced() async {
    try {
      // Perform the update query to set isSynced to 1 where it is currently 0
      await database.update(
        AppSecrets.techNotesTable,
        {
          "isSynced": 1, // Set to 1 (true)
        },
        where: 'isSynced = ?', // Where it is currently 0 (false/un-synced)
        whereArgs: [0],
      );
    } catch (e) {
      // Handle or log the error
      throw ServerExecptions('Failed to mark notes as synced: $e');
    }
  }

  @override
  Future<void> cacheTechNotes(List<TechNoteModel> notes) async {
    try {
      final batch = database.batch();

      for (var note in notes) {
        batch.insert(
          AppSecrets.techNotesTable,
          note.copyWith(isSynced: true).toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to cache notes: $e');
    }
  }

  @override
  Future<void> cacheTechNoteUsers(List<UserModel> users) async {
    try {
      final batch = database.batch();

      for (var user in users) {
        batch.insert(
          AppSecrets.techNoteUsersTable,
          user.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to cache note users: $e');
    }
  }

  @override
  Future<List<TechNoteModel>?> getCachedTechNotes() async {
    try {
      final maps = await database.query(AppSecrets.techNotesTable);

      if (maps.isEmpty) return null;

      return maps.map((note) => TechNoteModel.fromJson(note)).toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cached notes: $e');
    }
  }

  @override
  Future<List<UserModel>?> getCachedTechNoteUsers() async {
    try {
      final maps = await database.query(AppSecrets.techNoteUsersTable);

      if (maps.isEmpty) return null;

      return maps.map((user) => UserModel.formJson(user)).toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cached note users: $e');
    }
  }

  @override
  Future<void> clearTechNotes() async {
    try {
      await database.delete(AppSecrets.techNotesTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached notes: $e');
    }
  }

  @override
  Future<void> clearTechNoteUsers() async {
    try {
      await database.delete(AppSecrets.techNoteUsersTable);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached note users: $e');
    }
  }
}
