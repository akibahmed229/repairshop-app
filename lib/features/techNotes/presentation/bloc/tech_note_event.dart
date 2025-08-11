part of 'tech_note_bloc.dart';

@immutable
sealed class TechNoteEvent {
  const TechNoteEvent();
}

final class TechNotesGetEvent extends TechNoteEvent {
  const TechNotesGetEvent();
}

final class TechNoteCreateEvent extends TechNoteEvent {
  String userId;
  String title;
  String content;

  TechNoteCreateEvent({
    required this.userId,
    required this.title,
    required this.content,
  });
}

final class TechNoteUpdateEvent extends TechNoteEvent {
  String id;
  String userId;
  String title;
  String content;
  bool completed;

  TechNoteUpdateEvent({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.completed,
  });
}

final class TechNoteDeleteEvent extends TechNoteEvent {
  final String id;

  const TechNoteDeleteEvent({required this.id});
}

final class TechNotesGetAllUsersEvent extends TechNoteEvent {
  const TechNotesGetAllUsersEvent();
}
