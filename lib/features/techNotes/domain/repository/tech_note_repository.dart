import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';

abstract interface class TechNoteRepository {
  Future<Either<Failure, List<TechNoteEntities>>> getAllTechNotes();
}
