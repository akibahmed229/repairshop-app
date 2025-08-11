import 'package:fpdart/fpdart.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/error/failure.dart';
import 'package:repair_shop/core/error/other_execptions.dart';
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
    } on ServerExecptions catch (_) {
      return _getCachedTechNotesData(
        () => techNoteLocalDataSource.getCachedTechNotes(),
      );
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TechNoteEntities>> createTechNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final note = await techNoteRemoteDataSource.createTechNote(
          userId: userId,
          title: title,
          content: content,
        );

        return right(note);
      } else {
        return left(
          Failure(message: "Creating note failed no internet connection!"),
        );
      }
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  }) async {
    try {
      if (await connectionChecker.isConnected) {
        final note = await techNoteRemoteDataSource.updateTechNote(
          id: id,
          userId: userId,
          title: title,
          content: content,
          completed: completed,
        );

        return right(note);
      } else {
        return left(
          Failure(message: "Updating note failed no internet connection!"),
        );
      }
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> deleteTechNote({required String id}) async {
    try {
      if (await connectionChecker.isConnected) {
        final note = await techNoteRemoteDataSource.deleteTechNote(id: id);

        return right(note);
      } else {
        return left(
          Failure(message: "Deleting note failed no internet connection!"),
        );
      }
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntities>>> getAllTechNoteUsers() async {
    try {
      if (await connectionChecker.isConnected) {
        final users = await techNoteRemoteDataSource.getAllTechNoteUsers();

        return right(users);
      } else {
        return left(
          Failure(
            message: "Getting all note users failed no internet connection!",
          ),
        );
      }
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  Future<Either<Failure, List<TechNoteEntities>>> _getCachedTechNotesData(
    Future<List<TechNoteEntities>?> Function() fn,
  ) async {
    final cachedUser = await fn();
    if (cachedUser == null) {
      return left(Failure(message: "User not found"));
    }
    return right(cachedUser);
  }
}
