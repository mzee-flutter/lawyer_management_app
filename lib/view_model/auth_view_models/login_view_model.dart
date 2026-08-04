import 'dart:async';

import 'package:all/all.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/models/auth_models/login_request_model.dart';
import 'package:right_case/repository/auth_repository/login_repo.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/services/push_token_service.dart';

/// What the View needs to react to a login attempt — a message to show and
/// whether it succeeded. Deliberately dumb: it carries no BuildContext.
class LoginResult {
  const LoginResult.success(this.message) : success = true;
  const LoginResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

class LoginViewModel with ChangeNotifier {
  LoginViewModel(this._currentUserVM);

  final CurrentUserViewModel _currentUserVM;
  final LoginRepository _loginRepo = LoginRepository();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Returns a result for the View to show (snackbar/toast). Never touches
  /// BuildContext or Navigator — once _currentUserVM flips to authenticated,
  /// AuthGate swaps to HomeScreen on its own. No navigation call belongs here.
  Future<LoginResult> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      return const LoginResult.failure('All fields are required');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final authModel = await _loginRepo.loginUser(
        LoginRequestModel(email: email, password: password),
      );

      _currentUserVM.setAuthenticatedUser(authModel);

      unawaited(PushTokenService.instance.registerForUser(authModel.user.id));

      return LoginResult.success(
        '${authModel.user.name ?? 'Welcome'} logged in successfully',
      );
    } on ApiException catch (e, stack) {
      // Was previously a bare `catch (e, stack)` that discarded the real
      // backend message (e.g. "Invalid email or password") in favor of a
      // hardcoded generic string. This surfaces what the server actually said.
      debugPrint('Error in LoginViewModel: $e');
      debugPrint(stack.toString());
      return LoginResult.failure(
        e.message.isNotEmpty ? e.message : 'Login failed. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Error in LoginViewModel: $e');
      debugPrint(stack.toString());
      return const LoginResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    // The original never disposed these — a small but real leak on every
    // sign-in screen visit.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
