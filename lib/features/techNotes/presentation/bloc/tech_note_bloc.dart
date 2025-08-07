import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/usecase/usecase.dart';
import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';
import 'package:repair_shop/features/techNotes/domain/usecases/get_all_tech_notes.dart';

part 'tech_note_event.dart';
part 'tech_note_state.dart';

class TechNoteBloc extends Bloc<TechNoteEvent, TechNoteState> {
  final GetAllTechNotes _getAllTechNotes;

  TechNoteBloc({required GetAllTechNotes getAllTechNotes})
    : _getAllTechNotes = getAllTechNotes,
      super(TechNoteInitial()) {
    on<TechNoteEvent>((event, emit) => emit(TechNoteLoading()));
    on<TechNotesGetEvent>(_onTechNotesGetEvent);
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
}
