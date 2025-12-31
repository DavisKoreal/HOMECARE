import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:homecare0x1/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Mock user for development fallback
  User? _mockUser; 

  // Get current user (Maps Firebase User to App User model)
  Future<User?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      // In a real app, you'd fetch the role from Firestore here.
      // For now, returning a basic User object.
      return User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'User',
        email: fbUser.email ?? '',
        role: 'caregiver', // Default role if unknown
      );
    }
    return _mockUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _mockUser = null;
  }
  
  // ... (Other auth methods would go here)
}
