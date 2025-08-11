import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class UpdateTechNote implements Usecase<String, UpdateTechNoteParams> {
  final TechNoteRepository techNoteRepository;
  const UpdateTechNote({required this.techNoteRepository});

  @override
  Future<Either<Failure, String>> call(UpdateTechNoteParams params) async {
    return await techNoteRepository.updateTechNote(
      id: params.id,
      userId: params.userId,
      title: params.title,
      content: params.content,
      completed: params.completed,
    );
  }
}

class UpdateTechNoteParams {
  String id;
  String userId;
  String title;
  String content;
  bool completed;

  UpdateTechNoteParams({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.completed,
  });
}
