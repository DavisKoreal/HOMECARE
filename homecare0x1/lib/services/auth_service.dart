import 'package:homecare0x1/models/user.dart';

class AuthService {
  // Mock user database
  final Map<String, Map<String, String>> _mockUsers = {
    'admin@example.com': {
      'password': '123',
      'role': 'admin',
      'id': '123',
      'name': 'Admin User'
    },
    'caregiver@example.com': {
      'password': '123',
      'role': 'caregiver',
      'id': '123',
      'name': 'Caregiver User'
    },
    'family@example.com': {
      'password': '123',
      'role': 'family',
      'id': '123',
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
