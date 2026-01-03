import os

def fix_auth_role_fetching():
    target_dir = os.path.expanduser("~/Desktop/HOMECARE/homecare0x1")
    
    if not os.path.exists(target_dir):
        print(f"Error: Directory {target_dir} not found.")
        return

    print(f"Changing directory to: {target_dir}")
    os.chdir(target_dir)

    print("\n--- Fixing lib/services/auth_service.dart ---")
    auth_path = os.path.join("lib", "services", "auth_service.dart")
    
    auth_code = """import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homecare0x1/models/user.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mock user for development fallback (optional)
  User? _mockUser; 

  // Get current user (Fetches Role from Firestore)
  Future<User?> getCurrentUser() async {
    final fbUser = _firebaseAuth.currentUser;
    if (fbUser != null) {
      try {
        // Fetch user data from Firestore to get the real role
        final doc = await _firestore.collection('users').doc(fbUser.uid).get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return User(
            id: fbUser.uid,
            name: data['name'] ?? fbUser.displayName ?? 'User',
            email: fbUser.email ?? data['email'] ?? '',
            role: data['role'] ?? 'caregiver', // Fallback only if field missing
          );
        } else {
          // If user exists in Auth but not Firestore, create a default entry or return basic user
          // For now, we return a basic user but warn about missing role
          print("Warning: User document not found in Firestore for ${fbUser.uid}");
          return User(
            id: fbUser.uid,
            name: fbUser.displayName ?? 'User',
            email: fbUser.email ?? '',
            role: 'caregiver', // Default fallback
          );
        }
      } catch (e) {
        print("Error fetching user details: $e");
        // Fallback to basic auth info if Firestore fails
        return User(
          id: fbUser.uid,
          name: fbUser.displayName ?? 'User',
          email: fbUser.email ?? '',
          role: 'caregiver',
        );
      }
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
      rethrow; // Rethrow to let UI handle specific error codes
    }
    return null;
  }

  // Register
  Future<User?> register(String email, String password, String name, String role) async {
    try {
      // 1. Create Auth User
      final result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (result.user != null) {
        await result.user!.updateDisplayName(name);
        
        // 2. Create Firestore Document
        final newUser = User(id: result.user!.uid, name: name, email: email, role: role);
        await _firestore.collection('users').doc(newUser.id).set({
          'id': newUser.id,
          'name': newUser.name,
          'email': newUser.email,
          'role': newUser.role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return newUser;
      }
    } catch (e) {
      print("Registration failed: $e");
      rethrow;
    }
    return null;
  }
}
"""
    with open(auth_path, "w", encoding="utf-8") as f:
        f.write(auth_code)
    print("Updated AuthService to fetch roles from Firestore.")

if __name__ == "__main__":
    fix_auth_role_fetching()