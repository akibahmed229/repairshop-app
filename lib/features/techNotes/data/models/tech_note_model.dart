import 'package:repair_shop/features/techNotes/domain/entities/tech_note_entities.dart';

class TechNoteModel extends TechNoteEntities {
  const TechNoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.completed,
    required super.createdAt,
    required super.updatedAt,
    super.userName,
    super.userEmail,
    super.isSynced,
  });

  factory TechNoteModel.fromJson(Map<String, dynamic> json) {
    return TechNoteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      completed: json['completed'] is int
          ? json['completed'] == 1
          : json['completed'] == true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userName: json['userName'] ?? "",
      userEmail: json['userEmail'] ?? "",
      isSynced: json['isSynced'] == 1 || json['isSynced'] == true,
    );
  }

  TechNoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userEmail,
    bool? isSynced,
  }) {
    return TechNoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'completed': completed ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userName': userName,
      'userEmail': userEmail,
      "isSynced": (isSynced ?? false) ? 1 : 0,
    };
  }
}
