part of 'tech_note_bloc.dart';

// Define statuses to tell the UI what is currently happening
enum TechNoteStatus {
  initial,
  loading,
  success,
  failure,
  actionSuccess, // For toasts like "Note created!" or "Deleted!"
}

// A single class holding ALL data persistently
final class TechNoteState {
  final TechNoteStatus status;
  final List<TechNoteEntities> notes; // Holds notes list
  final List<UserEntities> users; // Holds users list
  final String? message; // For error messages or success toasts

  const TechNoteState({
    this.status = TechNoteStatus.initial,
    this.notes = const [],
    this.users = const [],
    this.message,
  });

  // The copyWith method is the key. It allows updating ONE field
  // while keeping the others (like keeping 'users' while updating 'notes')
  TechNoteState copyWith({
    TechNoteStatus? status,
    List<TechNoteEntities>? notes,
    List<UserEntities>? users,
    String? message,
  }) {
    return TechNoteState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      users: users ?? this.users,
      message: message ?? this.message,
    );
  }
}
