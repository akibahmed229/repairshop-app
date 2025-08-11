import 'package:repair_shop/core/common/entities/user_entities.dart';

class TechNoteUserModel extends UserEntities {
  const TechNoteUserModel({
    required super.id,
    required super.name,
    required super.email,
    super.roles,
    super.active,
    super.createdAt,
    super.updatedAt,
  });

  factory TechNoteUserModel.formJson(Map<String, dynamic> map) {
    return TechNoteUserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      roles:
          (map['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      active: map['active'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}
