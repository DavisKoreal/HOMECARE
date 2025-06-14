import 'package:homecare0x1/models/user.dart';

class AuthService {
  // Mock user database
  final Map<String, Map<String, String>> _mockUsers = {
    'admin@example.com': {
      'password': 'admin123',
      'role': 'admin',
      'id': 'admin1',
      'name': 'Admin User'
    },
    'caregiver@example.com': {
      'password': 'care123',
      'role': 'caregiver',
      'id': 'caregiver1',
      'name': 'Caregiver User'
    },
    'family@example.com': {
      'password': 'fam123',
      'role': 'family',
      'id': 'family1',
      'name': 'Family User'
    },
  };

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final userData = _mockUsers[email];
    if (userData != null && userData['password'] == password) {
      return User(
        id: userData['id']!,
        role: userData['role']!,
        name: userData['name']!,
        email: userData['email'] ?? email,
      );
    }
    return null;
  }
}
