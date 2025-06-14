import 'package:flutter/material.dart';
import 'package:homecare0x1/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
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
