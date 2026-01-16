import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/create_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/delete_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_note_users.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_notes.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/sync_all_tech_notes.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/update_tech_note.dart';

part 'tech_note_event.dart';
part 'tech_note_state.dart';

class TechNoteBloc extends Bloc<TechNoteEvent, TechNoteState> {
  final GetAllTechNotes _getAllTechNotes;
  final SyncAllTechNotes _syncAllTechNotes;
  final CreateTechNote _createTechNote;
  final UpdateTechNote _updateTechNote;
  final DeleteTechNote _deleteTechNote;
  final GetAllTechNoteUsers _getAllTechNoteUsers;

  TechNoteBloc({
    required GetAllTechNotes getAllTechNotes,
    required SyncAllTechNotes syncAllTechNotes,
    required CreateTechNote createTechNote,
    required UpdateTechNote updateTechNote,
    required DeleteTechNote deleteTechNote,
    required GetAllTechNoteUsers getAllTechNoteUsers,
  }) : _getAllTechNotes = getAllTechNotes,
       _syncAllTechNotes = syncAllTechNotes,
       _createTechNote = createTechNote,
       _updateTechNote = updateTechNote,
       _deleteTechNote = deleteTechNote,
       _getAllTechNoteUsers = getAllTechNoteUsers,
       super(const TechNoteState()) {
    // Generic loading handler
    on<TechNoteEvent>((event, emit) {
      // Don't show loading spinner if we are just deleting/updating silently
      if (state.status != TechNoteStatus.loading) {
        emit(state.copyWith(status: TechNoteStatus.loading));
      }
    });
    on<TechNotesGetEvent>(_onTechNotesGetEvent);
    on<TechNotesSyncEvent>(_onTechNotesSyncEvent);
    on<TechNoteCreateEvent>(_onTechNoteCreateEvent);
    on<TechNoteUpdateEvent>(_onTechNoteUpdateEvent);
    on<TechNoteDeleteEvent>(_onTechNoteDeleteEvent);
    on<TechNotesGetAllUsersEvent>(_onTechNotesGetAllUsersEvent);
  }

  void _onTechNotesGetEvent(
    TechNotesGetEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _getAllTechNotes(NoParams());

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      ((notes) => emit(
        // Updates notes, KEEPS users!
        state.copyWith(status: TechNoteStatus.success, notes: notes),
      )),
    );
  }

  void _onTechNotesSyncEvent(
    TechNotesSyncEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _syncAllTechNotes(NoParams());
    add(TechNotesGetEvent());

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      (_) {
        // Just emit success, TechNotesGetEvent will handle the data update
        emit(state.copyWith(status: TechNoteStatus.success));
      },
    );
  }

  void _onTechNoteCreateEvent(
    TechNoteCreateEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _createTechNote(
      CreateTechNoteParams(
        userId: event.userId,
        title: event.title,
        content: event.content,
        userName: event.userName,
        userEmail: event.userEmail,
      ),
    );

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      (note) {
        // Optimistic Update: Add new note to current list immediately
        final updatedNotes = List<TechNoteEntities>.from(state.notes)
          ..add(note);
        emit(
          state.copyWith(
            status: TechNoteStatus.actionSuccess, // Special status for Toasts
            message: "Note Created Successfully",
            notes: updatedNotes,
          ),
        );
      },
    );
  }

  void _onTechNoteUpdateEvent(
    TechNoteUpdateEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _updateTechNote(
      UpdateTechNoteParams(
        id: event.id,
        userId: event.userId,
        title: event.title,
        content: event.content,
        completed: event.completed,
      ),
    );

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      (message) {
        add(const TechNotesGetEvent()); // Refresh to be safe
        emit(
          state.copyWith(
            status: TechNoteStatus.actionSuccess,
            message: message,
          ),
        );
      },
    );
  }

  void _onTechNoteDeleteEvent(
    TechNoteDeleteEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _deleteTechNote(DeleteTechNoteParams(id: event.id));

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      (message) {
        // Optimistic delete: remove locally first for instant UI feedback
        final updatedNotes = state.notes
            .where((n) => n.id != event.id)
            .toList();
        emit(
          state.copyWith(
            status: TechNoteStatus.actionSuccess,
            message: message,
            notes: updatedNotes,
          ),
        );
      },
    );
  }

  void _onTechNotesGetAllUsersEvent(
    TechNotesGetAllUsersEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _getAllTechNoteUsers(NoParams());

    res.fold(
      (failure) => emit(
        state.copyWith(
          status: TechNoteStatus.failure,
          message: failure.message,
        ),
      ),
      (users) =>
          emit(state.copyWith(status: TechNoteStatus.success, users: users)), // Updates users, KEEPS notes!
    );
  }
}
