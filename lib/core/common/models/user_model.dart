import 'dart:convert';
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
      // 2. Handle both List (from API) and String (from DB)
      roles: _parseRoles(map['roles']),
      // 3. Handle both bool (from API) and int (from DB)
      active: map['active'] == 1 || map['active'] == true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),

      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      // 4. Encode List to String for SQLite TEXT column
      'roles': jsonEncode(roles),
      // 5. Convert bool to int for SQLite INTEGER column
      "active": active! ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper to handle roles coming from API (List) or DB (String)
  static List<String> _parseRoles(dynamic rolesData) {
    if (rolesData is String) {
      // It's coming from SQLite as a JSON string
      return (jsonDecode(rolesData) as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    } else if (rolesData is List) {
      // It's coming from API as a List
      return rolesData.map((e) => e.toString()).toList();
    }
    return [];
  }
}
