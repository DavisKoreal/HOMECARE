import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/user.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  Future<void> fetchUser(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        _user = User(
          id: userData['id'],
          role: userData['role'],
          name: userData['name'],
          email: userData['email'],
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  String getInitialRoute() {
    switch (_user?.role) {
      case 'admin':
        return '/admin_dashboard';
      case 'caregiver':
        return '/caregiver_dashboard';
      case 'family':
        return '/family_portal';
      default:
        return '/login';
    }
  }
}
