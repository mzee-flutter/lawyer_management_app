import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/auth_view/rc_auth_widgets.dart';

import '../../view_model/auth_view_models/forgot_password_view_model.dart';

class ForgotPasswordNewPasswordStep extends StatefulWidget {
  final VoidCallback onSuccess;

  const ForgotPasswordNewPasswordStep({super.key, required this.onSuccess});

  @override
  State<ForgotPasswordNewPasswordStep> createState() =>
      _ForgotPasswordNewPasswordStepState();
}

class _ForgotPasswordNewPasswordStepState
    extends State<ForgotPasswordNewPasswordStep> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // This is the step that was previously broken: the backend call succeeded
  // but nothing told the user, the fields stayed filled, and navigation
  // silently failed because it used the wrong Navigator API for a go_router
  // app. Fixed here: toast feedback either way, fields cleared and the
  // caller navigated away ONLY on success.
  Future<void> _submit(ForgotPasswordViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final result = await viewModel.resetPassword(_passwordController.text);
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (result.success) {
      _passwordController.clear();
      _confirmController.clear();
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              "Set a new password",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: RC.navy),
            ),
            const SizedBox(height: 8),
            const Text(
              "Choose a new password for your account. You'll need to log in again after this.",
              style:
                  TextStyle(fontSize: 14, color: RC.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _passwordController,
              obscureText: viewModel.obscurePassword,
              decoration: rcInputDecoration(label: "New password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: RC.textSecondary,
                  ),
                  onPressed: () => viewModel.toggleObscurePassword(),
                ),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return "Password must be at least 6 characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmController,
              obscureText: viewModel.obscureConfirm,
              decoration:
                  rcInputDecoration(label: "Confirm new password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    viewModel.obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: RC.textSecondary,
                  ),
                  onPressed: () => viewModel.toggleObscureConfirm(),
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return "Passwords don't match";
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(viewModel),
            ),
            const SizedBox(height: 24),
            RcPrimaryButton(
              label: "Reset password",
              isLoading: viewModel.isLoading,
              onPressed: () => _submit(viewModel),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
