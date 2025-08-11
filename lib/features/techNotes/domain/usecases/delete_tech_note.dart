import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class DeleteTechNote implements Usecase<String, DeleteTechNoteParams> {
  final TechNoteRepository techNoteRepository;
  const DeleteTechNote({required this.techNoteRepository});

  @override
  Future<Either<Failure, String>> call(DeleteTechNoteParams params) async {
    return await techNoteRepository.deleteTechNote(id: params.id);
  }
}

class DeleteTechNoteParams {
  String id;

  DeleteTechNoteParams({required this.id});
}
