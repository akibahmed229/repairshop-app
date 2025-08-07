import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/features/techNotes/data/datasources/tech_note_remote_data_source.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class TechNoteRepositoryImpl implements TechNoteRepository {
  final TechNoteRemoteDataSource techNoteRemoteDataSource;
  const TechNoteRepositoryImpl({required this.techNoteRemoteDataSource});

  @override
  Future<Either<Failure, List<TechNoteEntities>>> getAllTechNotes() async {
    try {
      final notes = await techNoteRemoteDataSource.getAllTechNotes();

      if (notes.isEmpty) {
        return left(Failure(message: "No notes exist"));
      }

      return right(notes); // ✅ now it's a match
    } on ServerExecptions catch (e) {
      return left(Failure(message: "Failed to fetch notes: ${e.message}"));
    }
  }
}
