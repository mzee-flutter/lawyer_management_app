import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/auth_view_models/login_view_model.dart';

import '../resources/system_design/auth_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginViewModel>().clearFields();
    });
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() => _shakeCtrl.forward(from: 0);

  // Was previously defined but never wired up -- the Sign In button called
  // loginVM.loginUser() directly, bypassing form validation entirely and
  // silently discarding the LoginResult (no error was ever shown on a
  // failed login).
  Future<void> _submit(LoginViewModel loginVM) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _shake();
      return;
    }

    final result = await loginVM.loginUser();
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (!result.success) {
      _shake();
      loginVM.passwordController.clear();
    }
    // On success, no navigation call here -- AuthGate reacts to
    // CurrentUserViewModel flipping to authenticated and swaps to
    // HomeScreen on its own.
  }

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final loginVM = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: RC.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHero(
              icon: Icons.balance_rounded,
              title: 'Welcome back, Counsel',
              subtitle: 'Sign in to manage your cases, hearings & clients',
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: loginVM.emailController,
                      label: 'Email address',
                      hint: 'you@lawfirm.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 500.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic),
                    SizedBox(height: 16.h),
                    AuthTextField(
                      controller: loginVM.passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(loginVM),
                    ).animate().fadeIn(delay: 580.ms, duration: 400.ms).slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 580.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic),
                    SizedBox(height: 10.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context
                            .pushNamed(RoutesName.forgotPasswordFlowScreen),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 30.h)),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: RC.gold,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp),
                        ),
                      ),
                    ).animate().fadeIn(delay: 650.ms, duration: 350.ms),
                    SizedBox(height: 12.h),
                    AuthPrimaryButton(
                      label: 'Sign In',
                      isLoading: loginVM.isLoading,
                      onPressed: () => _submit(loginVM),
                    )
                        .animate()
                        .fadeIn(delay: 720.ms, duration: 400.ms)
                        .scale(
                            begin: const Offset(0.94, 0.94),
                            end: const Offset(1, 1),
                            delay: 720.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack)
                        .shimmer(
                            delay: 1300.ms,
                            duration: 1100.ms,
                            color: Colors.white.withValues(alpha: 0.35)),
                    SizedBox(height: 28.h),
                    AuthFooterLink(
                      leading: "Don't have an account? ",
                      actionLabel: 'Create one',
                      onTap: () => context.pushNamed(RoutesName.signUpScreen),
                    ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(controller: _shakeCtrl, autoPlay: false).shake(
          hz: 4,
          offset: const Offset(8, 0),
          curve: Curves.easeInOut,
        );
  }
}
