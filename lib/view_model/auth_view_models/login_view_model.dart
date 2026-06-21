import 'package:flutter/material.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/repository/auth_repository/login_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/services/firebase_notification_service.dart';

class LoginViewModel with ChangeNotifier {
  final LoginRepository _loginRepo = LoginRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  User? _dbUser;
  User? get dbUser => _dbUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> loginUser(context) async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      SnakeBars.flutterToast('All fields are required', context);
      return false;
    }

    final existingUser = LoginRequestModel(email: email, password: password);

    _isLoading = true;
    notifyListeners();

    try {
      final user = await _loginRepo.loginUser(existingUser);
      _dbUser = user.user;
      notifyListeners();

      // ✅ FCM: get token and register it after login
      final token = await FirebaseNotificationService().getAndRegisterToken();
      if (token != null && _dbUser != null) {
        await _loginRepo.registerFCMToken(_dbUser!.id, token);
      }

      SnakeBars.flutterToast("${_dbUser?.name} login successfully", context);
      return true;
    } catch (e, stack) {
      debugPrint('Error in LoginViewModel: $e');
      debugPrint(stack.toString());

      SnakeBars.flutterToast('Login Failed. Try Again!', context);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }
}
