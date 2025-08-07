import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class GetAllTechNotes implements Usecase<List<TechNoteEntities>, NoParams> {
  final TechNoteRepository techNoteRepository;
  const GetAllTechNotes({required this.techNoteRepository});

  @override
  Future<Either<Failure, List<TechNoteEntities>>> call(NoParams params) async {
    return await techNoteRepository.getAllTechNotes();
  }
}
