part of 'tech_note_bloc.dart';

@immutable
sealed class TechNoteState {
  const TechNoteState();
}

final class TechNoteInitial extends TechNoteState {
  const TechNoteInitial();
}

final class TechNoteLoading extends TechNoteState {
  const TechNoteLoading();
}

final class TechNoteFailure extends TechNoteState {
  final String message;

  const TechNoteFailure({required this.message});
}

final class TechNotesGetSuccess extends TechNoteState {
  final List<TechNoteEntities> notes;

  const TechNotesGetSuccess(this.notes);
}
