import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/auth_view/rc_auth_widgets.dart';

import '../../view_model/auth_view_models/forgot_password_view_model.dart';

class ForgotPasswordEmailStep extends StatefulWidget {
  final VoidCallback onSuccess;

  const ForgotPasswordEmailStep({super.key, required this.onSuccess});

  @override
  State<ForgotPasswordEmailStep> createState() =>
      _ForgotPasswordEmailStepState();
}

class _ForgotPasswordEmailStepState extends State<ForgotPasswordEmailStep> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit(ForgotPasswordViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final result = await viewModel.requestOtp(_emailController.text.trim());
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (result.success) {
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
              "Forgot your password?",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: RC.navy),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter the email associated with your account and we'll send you a code to reset your password.",
              style:
                  TextStyle(fontSize: 14, color: RC.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              decoration: rcInputDecoration(
                  label: "Email address", hint: "you@lawfirm.com"),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!emailRegex.hasMatch(value.trim())) {
                  return "Enter a valid email address";
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(viewModel),
            ),
            const SizedBox(height: 24),
            RcPrimaryButton(
              label: "Send reset code",
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
