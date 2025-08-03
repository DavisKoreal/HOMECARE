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
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
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
      });

      return User(
        id: userId,
        role: role,
        name: name,
        email: email,
      );
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
}
