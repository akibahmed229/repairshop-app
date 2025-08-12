import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_with_users_entities.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class GetAllTechNotesWithUsers
    implements Usecase<TechNoteWithUsersEntities, NoParams> {
  final TechNoteRepository techNoteRepository;
  const GetAllTechNotesWithUsers({required this.techNoteRepository});

  @override
  Future<Either<Failure, TechNoteWithUsersEntities>> call(
    NoParams params,
  ) async {
    return await techNoteRepository.getAllTechNotesWithUsers();
  }
}
