import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';

import '../resources/system_design/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _confirmPasswordController = TextEditingController();
  late final AnimationController _shakeCtrl;

  // Captured once via didChangeDependencies — never re-read via context in
  // dispose(), since context.read() during dispose is unsafe with Provider.
  RegisterViewModel? _registerVM;

  bool _agreedToTerms = false; // must start unchecked — explicit consent only
  String _passwordValue = '';

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_registerVM == null) {
      _registerVM = context.read<RegisterViewModel>();
      _registerVM!.passwordController.addListener(_onPasswordChanged);
    }
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() => _passwordValue = _registerVM!.passwordController.text);
    }
  }

  @override
  void dispose() {
    _registerVM?.passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _shake() => _shakeCtrl.forward(from: 0);

  Future<void> _submit(RegisterViewModel registerVM) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _shake();
      return;
    }
    if (!_agreedToTerms) {
      _shake();
      SnakeBars.flutterToast(
          'Please agree to the Terms & Privacy Policy to continue', context);
      return;
    }

    final result = await registerVM.registerUser();
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (result.success) {
      registerVM.clearFields();
      _confirmPasswordController.clear();
      // No navigation call here -- registration authenticates the user
      // (same as login), so AuthGate reacts to CurrentUserViewModel and
      // swaps to HomeScreen on its own.
    } else {
      _shake();
      // Deliberately NOT clearing fields on failure (e.g. "email already
      // exists") -- forcing a full retype on every failed attempt is bad
      // UX. The user should only need to fix whatever was wrong.
    }
  }

  String? _validateName(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Full name is required';
    if (value.length < 3) return 'Enter your full name';
    return null;
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

  String? _validateConfirmPassword(String? v, RegisterViewModel vm) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != vm.passwordController.text) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final registerVM = context.watch<RegisterViewModel>();

    return Scaffold(
      backgroundColor: RC.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHero(
              icon: Icons.gavel_rounded,
              title: 'Create Your Chambers',
              subtitle: 'Set up your account to start managing cases',
              showBack: true,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: registerVM.nameController,
                      label: 'Full name',
                      hint: 'e.g. Ahmed Khan',
                      icon: Icons.person_outline_rounded,
                      validator: _validateName,
                    ).animate().fadeIn(delay: 450.ms, duration: 380.ms).slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 450.ms,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic),
                    SizedBox(height: 14.h),
                    AuthTextField(
                      controller: registerVM.emailController,
                      label: 'Email address',
                      hint: 'you@lawfirm.com',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ).animate().fadeIn(delay: 520.ms, duration: 380.ms).slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 520.ms,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic),
                    SizedBox(height: 14.h),
                    AuthTextField(
                      controller: registerVM.passwordController,
                      label: 'Password',
                      hint: 'Minimum 6 characters',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: _validatePassword,
                    ).animate().fadeIn(delay: 590.ms, duration: 380.ms).slideY(
                        begin: 0.12,
                        end: 0,
                        delay: 590.ms,
                        duration: 380.ms,
                        curve: Curves.easeOutCubic),
                    SizedBox(height: 8.h),
                    PasswordStrengthBar(password: _passwordValue)
                        .animate()
                        .fadeIn(delay: 650.ms, duration: 300.ms),
                    SizedBox(height: 14.h),
                    AuthTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm password',
                            hint: 'Re-enter your password',
                            icon: Icons.lock_person_outlined,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: (v) =>
                                _validateConfirmPassword(v, registerVM),
                            onFieldSubmitted: (_) => _submit(registerVM))
                        .animate()
                        .fadeIn(delay: 700.ms, duration: 380.ms)
                        .slideY(
                            begin: 0.12,
                            end: 0,
                            delay: 700.ms,
                            duration: 380.ms,
                            curve: Curves.easeOutCubic),
                    SizedBox(height: 16.h),
                    _TermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v),
                    ).animate().fadeIn(delay: 760.ms, duration: 350.ms),
                    SizedBox(height: 22.h),
                    AuthPrimaryButton(
                      label: 'Create Account',
                      isLoading: registerVM.isLoading,
                      onPressed: () => _submit(registerVM),
                    )
                        .animate()
                        .fadeIn(delay: 830.ms, duration: 400.ms)
                        .scale(
                            begin: const Offset(0.94, 0.94),
                            end: const Offset(1, 1),
                            delay: 830.ms,
                            duration: 400.ms,
                            curve: Curves.easeOutBack)
                        .shimmer(
                            delay: 1400.ms,
                            duration: 1100.ms,
                            color: Colors.white.withValues(alpha: 0.35)),
                    SizedBox(height: 26.h),
                    AuthFooterLink(
                      leading: 'Already have an account? ',
                      actionLabel: 'Sign in',
                      onTap: () => context.goNamed(RoutesName.signInScreen),
                    ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
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

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20.w,
              height: 20.w,
              margin: EdgeInsets.only(top: 1.h),
              decoration: BoxDecoration(
                color: value ? RC.navy : Colors.transparent,
                borderRadius: BorderRadius.circular(5.r),
                border:
                    Border.all(color: value ? RC.navy : RC.divider, width: 1.4),
              ),
              child: value
                  ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: 'I agree to the ',
                  style: RC
                      .caption(color: RC.textSecondary)
                      .copyWith(fontSize: 12.sp),
                  children: [
                    TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                            color: RC.navy, fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' and '),
                    TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                            color: RC.navy, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
