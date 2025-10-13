import 'package:flutter/material.dart';

import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/repository/auth_repository/register_repo.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';

class RegisterViewModel with ChangeNotifier {
  final RegisterRepository _registerRepo = RegisterRepository();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  User? _dbUser;
  User? get dbUser => _dbUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> registerUser(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
    }

    final newUser = RegisterRequestModel(
      name: name,
      email: email,
      password: password,
    );

    toggleLoading(true);
    try {
      final user = await _registerRepo.registerUser(newUser);

      _dbUser = user.user;
      toggleLoading(false);
      SnakeBars.flutterToast(
          '${_dbUser?.name} registered successfully', context);

      return true;
    } catch (e, stack) {
      debugPrint('Error in RegisterViewModel: $e');
      debugPrint('Stack: $stack');

      SnakeBars.flutterToast('Registration failed. Try again.', context);
      return false;
    } finally {
      toggleLoading(false);
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }
}
