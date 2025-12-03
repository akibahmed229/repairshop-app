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

        await techNoteLocalDataSource.clearTechNotes();
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
  Future<Either<Failure, bool>> syncAllTechNotes() async {
    try {
      if (await connectionChecker.isConnected) {
        final unSyncedTechNotes = await techNoteLocalDataSource
            .getUnSyncedTechNotes();

        if (unSyncedTechNotes.isEmpty) {
          return right(true);
        }

        final result = await techNoteRemoteDataSource.syncTechNotes(
          notes: unSyncedTechNotes,
        );

        if (result) {
          await techNoteLocalDataSource.markAllTechNotesAsSynced();
        }

        return right(result);
      } else {
        return left(Failure(message: "No Internet Connection!!!"));
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
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
        final note = await techNoteLocalDataSource.createTechNote(
          userId: userId,
          title: title,
          content: content,
        );

        return right(note);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
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
        final note = await techNoteLocalDataSource.updateTechNote(
          id: id,
          userId: userId,
          title: title,
          content: content,
          completed: completed,
        );

        return right(note);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
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
        final note = await techNoteLocalDataSource.deleteTechNote(id: id);

        return right(note);
      }
    } on ServerExecptions catch (e) {
      return left(Failure(message: e.message));
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<UserEntities>>> getAllTechNoteUsers() async {
    try {
      if (await connectionChecker.isConnected) {
        final users = await techNoteRemoteDataSource.getAllTechNoteUsers();

        if (users.isEmpty) {
          return left(Failure(message: "No note users exist"));
        }

        await techNoteLocalDataSource.clearTechNoteUsers();
        await techNoteLocalDataSource.cacheTechNoteUsers(users);

        return right(users);
      } else {
        final cachedTechnoteUsers = await techNoteLocalDataSource
            .getCachedTechNoteUsers();

        if (cachedTechnoteUsers == null) {
          return left(Failure(message: "tech note users not found"));
        }

        return right(cachedTechnoteUsers);
      }
    } on ServerExecptions catch (_) {
      return _getCachedTechNoteUsersData(
        () => techNoteLocalDataSource.getCachedTechNoteUsers(),
      );
    } on OtherExecptions catch (e) {
      return left(Failure(message: e.message));
    }
  }

  Future<Either<Failure, List<TechNoteEntities>>> _getCachedTechNotesData(
    Future<List<TechNoteEntities>?> Function() fn,
  ) async {
    final cachedUser = await fn();
    if (cachedUser == null) {
      return left(Failure(message: "Notes not found"));
    }
    return right(cachedUser);
  }

  Future<Either<Failure, List<UserEntities>>> _getCachedTechNoteUsersData(
    Future<List<UserEntities>?> Function() fn,
  ) async {
    final cachedUser = await fn();
    if (cachedUser == null) {
      return left(Failure(message: "Users not found"));
    }
    return right(cachedUser);
  }
}
