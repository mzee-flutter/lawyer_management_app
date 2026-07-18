import 'package:flutter/material.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/repository/auth_repository/change_password_repo.dart';

/// Mirrors LoginResult.
class ChangePasswordResult {
  const ChangePasswordResult.success(this.message) : success = true;
  const ChangePasswordResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

class ChangePasswordViewModel extends ChangeNotifier {
  final ChangePasswordRepo _changePasswordRepo;

  ChangePasswordViewModel({required ChangePasswordRepo changePasswordRepo})
      : _changePasswordRepo = changePasswordRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool get obscureCurrent => _obscureCurrent;
  bool get obscureNew => _obscureNew;
  bool get obscureConfirm => _obscureConfirm;

  void toggleObscureCurrent() {
    _obscureCurrent = !_obscureCurrent;
    notifyListeners();
  }

  void toggleObscureNew() {
    _obscureNew = !_obscureNew;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Token persistence now happens inside ChangePasswordRepo itself,
      // matching how Login/Register/Refresh all handle it at the repo
      // layer -- this ViewModel no longer needs to know about
      // TokenStorageService at all.
      final result = await _changePasswordRepo.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return ChangePasswordResult.success(result.message);
    } on ApiException catch (e, stack) {
      debugPrint('Error in ChangePasswordViewModel: $e');
      debugPrint(stack.toString());
      return ChangePasswordResult.failure(
        e.message.isNotEmpty
            ? e.message
            : 'Something went wrong. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Error in ChangePasswordViewModel: $e');
      debugPrint(stack.toString());
      return const ChangePasswordResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
