import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/network/connection_checker.dart';
import 'package:repair_shop/features/techNotes/data/datasources/tech_note_local_data_source.dart';
import 'package:repair_shop/features/techNotes/data/datasources/tech_note_remote_data_source.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/repository/tech_note_repository.dart';

class TechNoteRepositoryImpl implements TechNoteRepository {
  final TechNoteRemoteDataSource techNoteRemoteDataSource;
  final TechNoteLocalDataSource techNoteLocalDataSource;
  final ConnectionChecker connectionChecker;
  const TechNoteRepositoryImpl({
    required this.techNoteRemoteDataSource,
    required this.techNoteLocalDataSource,
    required this.connectionChecker,
  });

  @override
  Future<Either<Failure, List<TechNoteEntities>>> getAllTechNotes() async {
    try {
      if (await connectionChecker.isConnected) {
        final notes = await techNoteRemoteDataSource.getAllTechNotes();

        if (notes.isEmpty) {
          return left(Failure(message: "No notes exist"));
        }

        await techNoteLocalDataSource.cacheTechNotes(notes);

        return right(notes);
      } else {
        final cachedTechnotes = await techNoteLocalDataSource
            .getCachedTechNotes();

        if (cachedTechnotes == null) {
          return left(Failure(message: "tech notes not found"));
        }

        return right(cachedTechnotes);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: "Failed to fetch notes: ${e.message}"));
    }
  }
}
