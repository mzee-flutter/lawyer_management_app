import 'dart:async';

import 'package:flutter/material.dart';
import 'package:right_case/data/api_exception.dart';
import 'package:right_case/repository/auth_repository/forgot_password_repo.dart';
import 'package:right_case/repository/auth_repository/reset_password_repo.dart';
import 'package:right_case/repository/auth_repository/verify_otp_repo.dart';

/// Mirrors LoginResult — what the View needs to react to each step. No
/// BuildContext; the View decides what to do (toast, advance to the next
/// step) based on `success` and shows `message` either way.
class ForgotPasswordResult {
  const ForgotPasswordResult.success(this.message) : success = true;
  const ForgotPasswordResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}

/// Backs all three forgot-password screens. Create ONE instance at the
/// flow's entry point and keep it alive across all three steps -- if each
/// step screen creates its own instance, _email and _resetToken are lost
/// between steps and the flow breaks.
class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordRepo _forgotPasswordRepo;
  final VerifyOtpRepo _verifyOtpRepo;
  final ResetPasswordRepo _resetPasswordRepo;

  ForgotPasswordViewModel({
    required ForgotPasswordRepo forgotPasswordRepo,
    required VerifyOtpRepo verifyOtpRepo,
    required ResetPasswordRepo resetPasswordRepo,
  })  : _forgotPasswordRepo = forgotPasswordRepo,
        _verifyOtpRepo = verifyOtpRepo,
        _resetPasswordRepo = resetPasswordRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
    notifyListeners();
  }

  String? _email;
  String? get email => _email;

  String? _resetToken;

  /// OTP resend cooldown -- previously a Timer living in
  /// ForgotPasswordOtpStep's State, driven by setState() every tick. Moved
  /// here so the countdown survives independent of the View's lifecycle
  /// and is driven by the actual event that justifies it (a code was just
  /// sent), not by "this screen happened to build."
  static const int _resendCooldownSeconds =
      60; // mirrors OTP_RESEND_COOLDOWN_SECONDS default on the backend
  Timer? _resendCooldownTimer;

  int _resendCooldown = 0;
  int get resendCooldown => _resendCooldown;

  /// True once the countdown has hit zero AND no request is currently in
  /// flight. Views should gate the resend button on this instead of
  /// re-deriving the same condition themselves.
  bool get canResendOtp => _resendCooldown <= 0 && !_isLoading;

  void _startResendCooldown() {
    _resendCooldownTimer?.cancel();
    _resendCooldown = _resendCooldownSeconds;
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        _resendCooldown = 0;
      } else {
        _resendCooldown -= 1;
      }
      notifyListeners();
    });
  }

  /// OTP-box error styling -- previously a bool in the View's setState,
  /// which meant it could go stale (e.g. still showing a failed-attempt
  /// style after backing out and requesting a fresh code). Now it's
  /// explicitly cleared whenever a new OTP is successfully dispatched, and
  /// set only by a failed verifyOtp call.
  bool _otpHasError = false;
  bool get otpHasError => _otpHasError;

  /// Step 1: request an OTP for the given email. Backend always returns a
  /// generic success message regardless of whether the email exists, so a
  /// successful result here does NOT confirm the account exists -- don't
  /// build UI that implies otherwise.
  Future<ForgotPasswordResult> requestOtp(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _forgotPasswordRepo.requestOtp(email);
      _email = email;
      _otpHasError = false; // a fresh code invalidates any prior failure
      _startResendCooldown();
      return ForgotPasswordResult.success(response.message);
    } on ApiException catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.requestOtp: $e');
      debugPrint(stack.toString());
      return ForgotPasswordResult.failure(
        e.message.isNotEmpty
            ? e.message
            : 'Something went wrong. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.requestOtp: $e');
      debugPrint(stack.toString());
      return const ForgotPasswordResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 1b: resend, reusing the email already captured in step 1.
  Future<ForgotPasswordResult> resendOtp() {
    if (_email == null) {
      return Future.value(
        const ForgotPasswordResult.failure(
            'Something went wrong. Please start over.'),
      );
    }
    return requestOtp(_email!);
  }

  /// Step 2: verify the 6-digit code. On success, stores the short-lived
  /// reset token internally for step 3 -- it's never exposed to the View.
  Future<ForgotPasswordResult> verifyOtp(String otp) async {
    if (_email == null) {
      return const ForgotPasswordResult.failure(
          'Something went wrong. Please start over.');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _verifyOtpRepo.verifyOtp(email: _email!, otp: otp);
      _resetToken = result.resetToken;
      _otpHasError = false;
      return const ForgotPasswordResult.success('Code verified');
    } on ApiException catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.verifyOtp: $e');
      debugPrint(stack.toString());
      _otpHasError = true;
      return ForgotPasswordResult.failure(
        e.message.isNotEmpty ? e.message : 'Invalid or expired code',
      );
    } catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.verifyOtp: $e');
      debugPrint(stack.toString());
      _otpHasError = true;
      return const ForgotPasswordResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Step 3: set the new password using the token captured in step 2.
  /// After this succeeds, every session is revoked server-side -- the View
  /// should navigate to the login screen, not back into the app.
  Future<ForgotPasswordResult> resetPassword(String newPassword) async {
    if (_resetToken == null) {
      return const ForgotPasswordResult.failure(
          'Something went wrong. Please start over.');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _resetPasswordRepo.resetPassword(
        resetToken: _resetToken!,
        newPassword: newPassword,
      );
      _resetToken = null; // single-use; clear immediately
      return ForgotPasswordResult.success(response.message);
    } on ApiException catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.resetPassword: $e');
      debugPrint(stack.toString());
      return ForgotPasswordResult.failure(
        e.message.isNotEmpty
            ? e.message
            : 'Something went wrong. Please try again.',
      );
    } catch (e, stack) {
      debugPrint('Error in ForgotPasswordViewModel.resetPassword: $e');
      debugPrint(stack.toString());
      return const ForgotPasswordResult.failure(
        'Something went wrong. Please check your connection and try again.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Call when leaving the flow (cancel, successful completion) so a stale
  /// email/token/cooldown/error never lingers if the same instance gets
  /// reused.
  void reset() {
    _resendCooldownTimer?.cancel();
    _resendCooldown = 0;
    _otpHasError = false;
    _email = null;
    _resetToken = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _resendCooldownTimer?.cancel();
    super.dispose();
  }
}
