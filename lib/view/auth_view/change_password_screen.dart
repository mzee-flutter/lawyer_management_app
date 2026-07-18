import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
// Confirmed from your real repo files: the file is singular
// (network_api_service.dart) even though the class is NetworkApiServices.
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/repository/auth_repository/change_password_repo.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view/auth_view/rc_auth_widgets.dart';

import '../../view_model/auth_view_models/change_password_view_model.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(ChangePasswordViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final result = await viewModel.changePassword(
      currentPassword: _currentController.text,
      newPassword: _newController.text,
    );
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (result.success) {
      _currentController.clear();
      _newController.clear();
      _confirmController.clear();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(
        changePasswordRepo: ChangePasswordRepo(NetworkApiServices()),
      ),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: RC.surface,
            appBar: AppBar(
              backgroundColor: RC.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: RC.navy),
              title: const Text(
                "Change password",
                style: TextStyle(color: RC.navy, fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _currentController,
                        obscureText: viewModel.obscureCurrent,
                        decoration: rcInputDecoration(label: "Current password")
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: RC.textSecondary,
                            ),
                            onPressed: () => viewModel.toggleObscureCurrent(),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? "Enter your current password"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newController,
                        obscureText: viewModel.obscureNew,
                        decoration:
                            rcInputDecoration(label: "New password").copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              viewModel.obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: RC.textSecondary,
                            ),
                            onPressed: () => viewModel.toggleObscureNew(),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          if (value == _currentController.text) {
                            return "New password must be different from your current password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: viewModel.obscureConfirm,
                        decoration:
                            rcInputDecoration(label: "Confirm new password")
                                .copyWith(
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
                        validator: (value) => value != _newController.text
                            ? "Passwords don't match"
                            : null,
                        onFieldSubmitted: (_) => _submit(viewModel),
                      ),
                      const SizedBox(height: 28),
                      RcPrimaryButton(
                        label: "Update password",
                        isLoading: viewModel.isLoading,
                        onPressed: () => _submit(viewModel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
