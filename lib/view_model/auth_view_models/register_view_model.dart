import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/auth_models/auth_model.dart';
import 'package:right_case/models/auth_models/register_request_model.dart';
import 'package:right_case/repository/auth_repository/notification_token_repo.dart';
import 'package:right_case/repository/auth_repository/register_repo.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/firebase_notification_service.dart';

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
  final NotificationTokenRepo _notificationTokenRepo = NotificationTokenRepo();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  User? _dbUser;
  User? get dbUser => _dbUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

      // Backend authenticates on registration (same AuthResponse shape as
      // login) -- previously this was thrown away and only `.user` was
      // read, so the app's live session state never learned a user had
      // just registered (AuthGate had nothing to react to).
      _currentUserVM.setAuthenticatedUser(authModel);

      // Same as LoginViewModel: best-effort, fire-and-forget, never allowed
      // to fail a registration that already succeeded.
      unawaited(_registerPushToken(authModel.user.id));
      _initTokenRefreshListener(authModel.user.id);

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

  Future<void> _registerPushToken(String? userId) async {
    if (userId == null) return;
    try {
      final token = await FirebaseNotificationService().getAndRegisterToken();
      if (token != null) {
        await _notificationTokenRepo.registerFCMToken(userId, token);
      }
    } catch (e) {
      debugPrint('FCM registration failed (non-fatal): $e');
    }
  }

  void _initTokenRefreshListener(String userId) {
    _messaging.onTokenRefresh.listen((newToken) async {
      await _notificationTokenRepo.registerFCMToken(userId, newToken);
    });
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
