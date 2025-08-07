part of 'tech_note_bloc.dart';

@immutable
sealed class TechNoteEvent {
  const TechNoteEvent();
}

final class TechNotesGetEvent extends TechNoteEvent {
  const TechNotesGetEvent();
}
