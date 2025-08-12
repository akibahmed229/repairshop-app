import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';

class TechNoteWithUsersEntities {
  List<TechNoteEntities> notes;
  List<UserEntities> users;

  TechNoteWithUsersEntities({required this.users, required this.notes});
}
