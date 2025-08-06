class UserEntities {
  final String id;
  final String name;
  final String email;
  final List<String>? roles;
  final bool? active;
  final String? token;

  const UserEntities({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
    required this.active,
    this.token,
  });
}
