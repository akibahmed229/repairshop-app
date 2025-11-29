import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_user_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class TechNoteLocalDataSource {
  Future<void> cacheTechNotes(List<TechNoteModel> notes);
  Future<void> cacheTechNoteUsers(List<TechNoteUserModel> users);
  Future<List<TechNoteModel>?> getCachedTechNotes();
  Future<List<TechNoteUserModel>?> getCachedTechNoteUsers();
  Future<void> clearTechNotes();
  Future<void> clearTechNoteUsers();
}

class TechNoteLocalDataSourceImpl implements TechNoteLocalDataSource {
  final Database database;
  const TechNoteLocalDataSourceImpl({required this.database});

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
  Future<void> cacheTechNoteUsers(List<TechNoteUserModel> users) async {
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
  Future<List<TechNoteUserModel>?> getCachedTechNoteUsers() async {
    try {
      final maps = await database.query(AppSecrets.techNoteUsersTable);

      if (maps.isEmpty) return null;

      return maps.map((user) => TechNoteUserModel.formJson(user)).toList();
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
