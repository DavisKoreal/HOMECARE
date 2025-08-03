import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:homecare0x1/models/user.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login(String email, String password) async {
    try {
      // Authenticate with Firebase Authentication
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final docSnapshot =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        return User(
          id: userData['id'] as String,
          role: userData['role'] as String,
          name: userData['name'] as String,
          email: userData['email'] as String,
        );
      }
      throw Exception('User data not found in Firestore');
    } on auth.FirebaseAuthException catch (e) {
      throw e; // Re-throw for handling in UI
    } catch (e) {
      print('Login error: $e');
      throw Exception('Failed to login: $e');
    }
  }

  // Register a new user (for setup or registration)
  Future<User?> register({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    try {
      // Check if user already exists
      try {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print('User $email already exists, skipping registration');
        return null;
      } on auth.FirebaseAuthException catch (e) {
        if (e.code != 'user-not-found') {
          throw e; // Other errors should be handled
        }
      }

      // Create user in Firebase Authentication
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      final userId = credential.user!.uid;
      await _firestore.collection('users').doc(userId).set({
        'id': userId,
        'email': email,
        'role': role,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return User(
        id: userId,
        role: role,
        name: name,
        email: email,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw e; // Re-throw for handling in UI
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Failed to register: $e');
    }
  }
}
