class User {
  final String id;
  final String role; // e.g., 'admin', 'caregiver', 'family'
  final String name;
  final String email;

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
  });
}
