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
      return User(
        id: fbUser.uid,
        name: fbUser.displayName ?? 'User',
        email: fbUser.email ?? '',
        role: 'caregiver', // Default role logic should ideally fetch from DB
      );
    }
    return _mockUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _mockUser = null;
  }

  // Login
  Future<User?> login(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        return await getCurrentUser();
      }
    } catch (e) {
      print("Login failed: $e");
      // Fallback for dev mode if needed, or rethrow
    }
    return null;
  }

  // Register
  Future<User?> register(String email, String password, String name, String role) async {
    try {
      final result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        // Here you would typically also create a User document in Firestore
        return User(id: result.user!.uid, name: name, email: email, role: role);
      }
    } catch (e) {
      print("Registration failed: $e");
    }
    return null;
  }
}
