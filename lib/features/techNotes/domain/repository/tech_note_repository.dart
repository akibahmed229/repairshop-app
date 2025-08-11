import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';

abstract interface class TechNoteRepository {
  Future<Either<Failure, List<TechNoteEntities>>> getAllTechNotes();

  Future<Either<Failure, TechNoteEntities>> createTechNote({
    required String userId,
    required String title,
    required String content,
  });

  Future<Either<Failure, String>> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  });

  Future<Either<Failure, String>> deleteTechNote({required String id});

  Future<Either<Failure, List<UserEntities>>> getAllTechNoteUsers();
}
