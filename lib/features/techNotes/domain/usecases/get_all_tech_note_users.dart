import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class GetAllTechNoteUsers implements Usecase<List<UserEntities>, NoParams> {
  final TechNoteRepository techNoteRepository;
  const GetAllTechNoteUsers({required this.techNoteRepository});

  @override
  Future<Either<Failure, List<UserEntities>>> call(NoParams params) async {
    return await techNoteRepository.getAllTechNoteUsers();
  }
}
