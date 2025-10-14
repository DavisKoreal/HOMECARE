import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:homecare0x1/models/user.dart';
import 'package:homecare0x1/services/auditlog_service.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuditLogService _auditLogService = FirebaseAuditLogService.instance;

  // Future<User?> login(String email, String password) async {
  //   try {
  //     // Authenticate with Firebase Authentication
  //     final credential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );

  //     // Fetch user data from Firestore
  //     final docSnapshot =
  //         await _firestore.collection('users').doc(credential.user!.uid).get();
  //     if (docSnapshot.exists) {
  //       print("A document snapshot exists");
  //       final userData = docSnapshot.data()!;
  //       return User(
  //         id: userData['id'] as String,
  //         role: userData['role'] as String,
  //         name: userData['name'] as String,
  //         email: userData['email'] as String,
  //       );
  //     }
  //     throw Exception('User data not found in Firestore');
  //   } on auth.FirebaseAuthException catch (e) {
  //     throw e; // Re-throw for handling in UI
  //   } catch (e) {
  //     print('Login error: $e');
  //     throw Exception('Failed to login: $e');
  //   }
  // }

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
        // print("A document snapshot exists");
        final userData = docSnapshot.data()!;
        // Create audit log entry for login
        await _auditLogService.createAuditLog(
          userId: userData['id'] as String,
          userName: userData['name'] as String,
          userRole: userData['role'] as String,
          action: 'User logged in',
          actionType: 'login',
          severity: 'security',
          details: 'User ID: ${userData['id']}, Email: $email',
        );
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

Future<User?> register({
  required String email,
  required String password,
  required String role,
  required String name,
}) async {
  try {
    // Check if user already exists
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('User $email already exists, skipping registration');
      return null;
    } on auth.FirebaseAuthException catch (e) {
      if (e.code != 'user-not-found' && e.code != 'invalid-credential') {
        print("Some other error has been found when trying to sign in with the user and the password");
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

    print("Currently ready to return the user ");

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
