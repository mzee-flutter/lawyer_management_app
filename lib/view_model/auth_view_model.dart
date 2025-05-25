// viewmodels/auth_viewmodel.dart
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  String? _userEmail;
  String? get userEmail => _userEmail;

  bool signIn(String email, String password) {
    // Dummy check
    if (email.isNotEmpty && password.isNotEmpty) {
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool signUp(String email, String password) {
    // Dummy sign-up logic
    if (email.isNotEmpty && password.length >= 6) {
      _userEmail = email;
      notifyListeners();
      return true;
    }
    return false;
  }

  void signOut() {
    _userEmail = null;
    notifyListeners();
  }
}
