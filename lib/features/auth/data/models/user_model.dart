import 'package:repair_shop/core/common/entities/user_entities.dart';

class UserModel extends UserEntities {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.roles,
    super.active,
    super.createdAt,
    super.updatedAt,
    super.token,
  });

  factory UserModel.formJson(Map<String, dynamic> map) {
    return UserModel(
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

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? roles,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }
}
