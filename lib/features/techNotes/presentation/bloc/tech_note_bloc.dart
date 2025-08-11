import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/entities/user_entities.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/create_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/delete_tech_note.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_note_users.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_notes.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/update_tech_note.dart';

part 'tech_note_event.dart';
part 'tech_note_state.dart';

class TechNoteBloc extends Bloc<TechNoteEvent, TechNoteState> {
  final GetAllTechNotes _getAllTechNotes;
  final CreateTechNote _createTechNote;
  final UpdateTechNote _updateTechNote;
  final DeleteTechNote _deleteTechNote;
  final GetAllTechNoteUsers _getAllTechNoteUsers;

  TechNoteBloc({
    required GetAllTechNotes getAllTechNotes,
    required CreateTechNote createTechNote,
    required UpdateTechNote updateTechNote,
    required DeleteTechNote deleteTechNote,
    required GetAllTechNoteUsers getAllTechNoteUsers,
  }) : _getAllTechNotes = getAllTechNotes,
       _createTechNote = createTechNote,
       _updateTechNote = updateTechNote,
       _deleteTechNote = deleteTechNote,
       _getAllTechNoteUsers = getAllTechNoteUsers,
       super(TechNoteInitial()) {
    on<TechNoteEvent>((event, emit) => emit(TechNoteLoading()));
    on<TechNotesGetEvent>(_onTechNotesGetEvent);
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
      (failure) => emit(TechNoteFailure(message: failure.message)),
      ((notes) => emit(TechNotesGetSuccess(notes))),
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
      ),
    );

    res.fold(
      (failure) => emit(TechNoteFailure(message: failure.message)),
      (note) => emit(TechNoteCreateSuccess(note)),
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
      (failure) => emit(TechNoteFailure(message: failure.message)),
      (message) => emit(TechNoteUpdateAndDeleteSuccess(message)),
    );
  }

  void _onTechNoteDeleteEvent(
    TechNoteDeleteEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _deleteTechNote(DeleteTechNoteParams(id: event.id));

    res.fold(
      (failure) => emit(TechNoteFailure(message: failure.message)),
      (message) => emit(TechNoteUpdateAndDeleteSuccess(message)),
    );
  }

  void _onTechNotesGetAllUsersEvent(
    TechNotesGetAllUsersEvent event,
    Emitter<TechNoteState> emit,
  ) async {
    final res = await _getAllTechNoteUsers(NoParams());

    res.fold(
      (failure) => emit(TechNoteFailure(message: failure.message)),
      (users) => emit(TechNotesGetAllUsersSuccess(users)),
    );
  }
}
