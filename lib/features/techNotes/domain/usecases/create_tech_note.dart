import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class CreateTechNote
    implements Usecase<TechNoteEntities, CreateTechNoteParams> {
  final TechNoteRepository techNoteRepository;
  const CreateTechNote({required this.techNoteRepository});

  @override
  Future<Either<Failure, TechNoteEntities>> call(
    CreateTechNoteParams params,
  ) async {
    return await techNoteRepository.createTechNote(
      userId: params.userId,
      title: params.title,
      content: params.content,
    );
  }
}

class CreateTechNoteParams {
  String userId;
  String title;
  String content;
  CreateTechNoteParams({
    required this.userId,
    required this.title,
    required this.content,
  });
}
