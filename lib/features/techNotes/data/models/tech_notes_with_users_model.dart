import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_user_model.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_with_users_entities.dart';

class TechNotesWithUsersModel extends TechNoteWithUsersEntities {
  TechNotesWithUsersModel({required super.notes, required super.users});

  factory TechNotesWithUsersModel.fromJson(Map<String, dynamic> map) {
    final notesJson = map['notes'] as List<dynamic>? ?? [];
    final usersJson = map['users'] as List<dynamic>? ?? [];

    final notes = notesJson
        .map(
          (noteMap) => TechNoteModel.fromJson(noteMap as Map<String, dynamic>),
        )
        .toList();

    final users = usersJson
        .map(
          (userMap) =>
              TechNoteUserModel.fromJson(userMap as Map<String, dynamic>),
        )
        .toList();

    return TechNotesWithUsersModel(notes: notes, users: users);
  }
}
