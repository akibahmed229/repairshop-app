class UserEntities {
  final String id;
  final String name;
  final String email;
  final String? token;

  const UserEntities({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });
}
