class User {
  final String id;
  final String role; // e.g., 'admin', 'caregiver', 'family'
  final String name;

  User({
    required this.id,
    required this.role,
    required this.name,
  });
}
