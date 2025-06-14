import 'package:homecare0x1/models/user.dart';

class AuthService {
  // Mock user database
  final Map<String, Map<String, String>> _mockUsers = {
    'admin@example.com': {'password': 'admin123', 'role': 'admin', 'id': 'admin1'},
    'caregiver@example.com': {'password': 'care123', 'role': 'caregiver', 'id': 'caregiver1'},
    'family@example.com': {'password': 'fam123', 'role': 'family', 'id': 'family1'},
  };

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final userData = _mockUsers[email];
    if (userData != null && userData['password'] == password) {
      return User(id: userData['id']!, role: userData['role']!);
    }
    return null;
  }
}