import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class SyncAllTechNotes implements Usecase<bool, NoParams> {
  final TechNoteRepository techNoteRepository;
  const SyncAllTechNotes({required this.techNoteRepository});

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await techNoteRepository.syncAllTechNotes();
  }
}
