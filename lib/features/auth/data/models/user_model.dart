import 'package:repair_shop/core/common/entities/user_entities.dart';

class UserModel extends UserEntities {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.roles,
    super.active,
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
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<String>? roles,
    bool? active,
    String? token,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      active: active ?? this.active,
      token: token ?? this.token,
    );
  }
}
