import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() => _shakeCtrl.forward(from: 0);

  Future<void> _submit(LoginViewModel loginVM) async {
    if (!_formKey.currentState!.validate()) {
      _shake();
      return;
    }
    final success = await loginVM.loginUser(context);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
    } else {
      _shake();
      SnakeBars.flutterToast(
          'Incorrect email or password. Please try again.', context);
    }
    loginVM.clearFields();
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
                        onPressed: () => Navigator.pushNamed(
                            context, RoutesName.forgotPasswordScreen),
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
                      onTap: () =>
                          Navigator.pushNamed(context, RoutesName.signUpScreen),
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
