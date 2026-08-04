import 'dart:async';

import 'package:flutter/material.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/repository/auth_repository/register_repo.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/push_token_service.dart';

/// Mirrors LoginResult — what the View needs to react to a registration
/// attempt. No BuildContext, no navigation: AuthGate reacts to
/// CurrentUserViewModel flipping to authenticated and swaps screens itself.
class RegisterResult {
  const RegisterResult.success(this.message) : success = true;
  const RegisterResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

class RegisterViewModel with ChangeNotifier {
  RegisterViewModel(this._currentUserVM);

  final CurrentUserViewModel _currentUserVM;
  final RegisterRepository _registerRepo = RegisterRepository();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  User? _dbUser;
  User? get dbUser => _dbUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  void toggleAgreedToTermCheckbox() {
    _agreedToTerms = !_agreedToTerms;
    notifyListeners();
  }

  Future<RegisterResult> registerUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return const RegisterResult.failure('All fields are required');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newUser =
          RegisterRequestModel(name: name, email: email, password: password);
      final authModel = await _registerRepo.registerUser(newUser);

      _dbUser = authModel.user;

      _currentUserVM.setAuthenticatedUser(authModel);

      unawaited(PushTokenService.instance.registerForUser(authModel.user.id));

      return RegisterResult.success(
        '${_dbUser?.name ?? 'Account'} created successfully',
      );
    } on ApiException catch (e, stack) {
      debugPrint('Error in RegisterViewModel: $e');
      debugPrint(stack.toString());

      // 409 = email already registered. DuplicateAutoTaskException is a
      // misleading name for this -- NetworkApiServices throws it for every
      // generic 409 the backend returns, not just auto-task conflicts.
      // Worth renaming to something like ConflictException on the network
      // layer so catches like this one read clearly.
      if (e is DuplicateAutoTaskException) {
        return const RegisterResult.failure(
          'An account with this email already exists. Try signing in instead.',
        );
      }
      return RegisterResult.failure(
        e.message.isNotEmpty
            ? e.message
            : 'Registration failed. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Error in RegisterViewModel: $e');
      debugPrint(stack.toString());
      return const RegisterResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFields() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    // The original never disposed these either — same leak as the
    // pre-fix LoginViewModel had, on every sign-up screen visit.
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
