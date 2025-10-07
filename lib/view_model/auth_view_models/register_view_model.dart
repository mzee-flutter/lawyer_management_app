import 'package:flutter/material.dart';

import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/models/auth_models/user_model.dart';
import 'package:right_case/repository/auth_repository/register_repo.dart';

class RegisterViewModel with ChangeNotifier {
  final RegisterRepository _registerRepo = RegisterRepository();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void toggleLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<UserModel?> registerUser(BuildContext context) async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('All fields are required')));
      return null;
    }

    final newUser = RegisterRequestModel(
      name: name,
      email: email,
      password: password,
    );

    toggleLoading(true);
    try {
      final user = await _registerRepo.registerUser(newUser);

      _user = user;
      toggleLoading(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ${user.name} registered successfully')),
      );

      return user;
    } catch (e, stack) {
      debugPrint('Error in RegisterViewModel: $e');
      debugPrint('Stack: $stack');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed. Try again.')),
      );
      return null;
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
