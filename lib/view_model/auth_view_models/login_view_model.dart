import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/repository/auth_repository/login_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/auth_view_models/login_user_info_view_model.dart';
import 'package:right_case/models/auth_models/auth_model.dart';

class LoginViewModel with ChangeNotifier {
  final _loginRepo = LoginRepository();

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('All fields are required ')));
    }

    final existingUser = LoginRequestModel(email: email, password: password);
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _loginRepo.loginUser(existingUser);
      _dbUser = user.user;
      _isLoading = false;
      notifyListeners();
      SnakeBars.flutterToast("${_dbUser?.name} login successfully", context);
      return true;
    } catch (e, stack) {
      debugPrint('Error in LoginViewModel: $e');
      debugPrint(stack.toString());

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login Failed. Try Again!')));
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
