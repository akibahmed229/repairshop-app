import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:sqflite/sqflite.dart';

abstract interface class TechNoteLocalDataSource {
  Future<void> cacheTechNotes(List<TechNoteModel> notes);
  Future<List<TechNoteModel>?> getCachedTechNotes();
  Future<void> clearTechNotes();
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
          note.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw ServerExecptions('Failed to clear cached tech notes: $e');
    }
  }

  @override
  Future<List<TechNoteModel>?> getCachedTechNotes() async {
    try {
      final maps = await database.query(AppSecrets.techNotesTable);

      if (maps.isEmpty) return null;

      return maps.map((note) => TechNoteModel.fromJson(note)).toList();
    } catch (e) {
      throw ServerExecptions('Failed to get cached tech notes: $e');
    }
  }

  @override
  Future<void> clearTechNotes() async {
    try {
      await database.delete(AppSecrets.techNotesTable);
    } catch (e) {
      throw ServerExecptions('Failed to cache tech notes: $e');
    }
  }
}
