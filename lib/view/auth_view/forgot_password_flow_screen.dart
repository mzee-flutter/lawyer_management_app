import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/repository/auth_repository/forgot_password_repo.dart';
import 'package:right_case/repository/auth_repository/reset_password_repo.dart';
import 'package:right_case/repository/auth_repository/verify_otp_repo.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/routes/routes_names.dart';

import '../../view_model/auth_view_models/forgot_password_view_model.dart';
import 'forgot_password_email_step.dart';
import 'forgot_password_new_password_step.dart';
import 'forgot_password_otp_step.dart';

enum _Step { email, otp, newPassword }

class ForgotPasswordFlowScreen extends StatefulWidget {
  const ForgotPasswordFlowScreen({super.key});

  @override
  State<ForgotPasswordFlowScreen> createState() =>
      _ForgotPasswordFlowScreenState();
}

class _ForgotPasswordFlowScreenState extends State<ForgotPasswordFlowScreen> {
  _Step _step = _Step.email;

  void _goTo(_Step step) => setState(() => _step = step);

  // Was previously using Navigator.of(context).pop()/pushNamedAndRemoveUntil,
  // which doesn't match how the rest of the app navigates (go_router). Back
  // here uses context.pop() to unwind the pushed route the same way
  // SignInScreen pushed it (context.pushNamed(RoutesName.forgotPasswordFlowScreen)).
  void _handleBack() {
    switch (_step) {
      case _Step.email:
        context.pop();
        break;
      case _Step.otp:
        _goTo(_Step.email);
        break;
      case _Step.newPassword:
        // Deliberately not routed back to the OTP step -- the code was
        // already consumed. Back here just exits the flow entirely.
        context.pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(
        forgotPasswordRepo: ForgotPasswordRepo(NetworkApiServices()),
        verifyOtpRepo: VerifyOtpRepo(NetworkApiServices()),
        resetPasswordRepo: ResetPasswordRepo(NetworkApiServices()),
      ),
      child: Scaffold(
        backgroundColor: RC.background,
        appBar: AppBar(
          backgroundColor: RC.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: RC.navy),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case _Step.email:
        return ForgotPasswordEmailStep(
          key: const ValueKey('email-step'),
          onSuccess: () => _goTo(_Step.otp),
        );
      case _Step.otp:
        return ForgotPasswordOtpStep(
          key: const ValueKey('otp-step'),
          onSuccess: () => _goTo(_Step.newPassword),
        );
      case _Step.newPassword:
        return ForgotPasswordNewPasswordStep(
          key: const ValueKey('new-password-step'),
          onSuccess: () {
            // Every session was revoked server-side as part of the reset,
            // so this device wasn't left logged in anyway -- send to login.
            // goNamed (not pushNamed) replaces the stack so the back button
            // can't return into the completed reset flow.
            context.goNamed(RoutesName.signInScreen);
          },
        );
    }
  }
}
