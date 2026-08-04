import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';

import '../resources/system_design/auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final AnimationController _shakeCtrl;
  bool _emailSent = false;
  String _sentTo = '';

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

  String? _validateEmail(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Future<void> _submit(LoginAndSignUpViewModel vm) async {
  //   if (!_formKey.currentState!.validate()) {
  //     _shake();
  //     return;
  //   }
  //   final email = vm.emailController.text.trim();
  //   try {
  //     // Previously called without `await` — errors were silently swallowed.
  //     // await vm.resetPassword(context);
  //     if (!mounted) return;
  //     setState(() {
  //       _emailSent = true;
  //       _sentTo = email;
  //     });
  //   } catch (_) {
  //     if (!mounted) return;
  //     _shake();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final vm = context.watch<LoginAndSignUpViewModel>();

    return Scaffold(
      backgroundColor: RC.background,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHero(
              icon: _emailSent
                  ? Icons.mark_email_read_outlined
                  : Icons.lock_reset_rounded,
              title: _emailSent ? 'Check Your Inbox' : 'Reset Password',
              subtitle: _emailSent
                  ? 'We sent recovery instructions to $_sentTo'
                  : 'Enter your registered email to receive reset instructions',
              showBack: true,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
              child: _emailSent
                  ? _SuccessPanel(onBackToLogin: () => Navigator.pop(context))
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthTextField(
                            controller: TextEditingController(),
                            // controller: vm.emailController,
                            label: 'Email address',
                            hint: 'you@lawfirm.com',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator: _validateEmail,
                            // onFieldSubmitted: (_) => _submit(vm),
                          )
                              .animate()
                              .fadeIn(delay: 450.ms, duration: 380.ms)
                              .slideY(
                                  begin: 0.12,
                                  end: 0,
                                  delay: 450.ms,
                                  duration: 380.ms,
                                  curve: Curves.easeOutCubic),
                          SizedBox(height: 24.h),
                          AuthPrimaryButton(
                            label: 'Send Reset Link',
                            isLoading: false,
                            onPressed: () {},
                            // isLoading: vm.isLoading,
                            // onPressed: () => _submit(vm),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 400.ms)
                              .scale(
                                  begin: const Offset(0.94, 0.94),
                                  end: const Offset(1, 1),
                                  delay: 600.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack)
                              .shimmer(
                                  delay: 1100.ms,
                                  duration: 1100.ms,
                                  color: Colors.white.withValues(alpha: 0.35)),
                          SizedBox(height: 26.h),
                          AuthFooterLink(
                            leading: 'Remember your password? ',
                            actionLabel: 'Sign in',
                            onTap: () => Navigator.pop(context),
                          ).animate().fadeIn(delay: 750.ms, duration: 400.ms),
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

class _SuccessPanel extends StatelessWidget {
  final VoidCallback onBackToLogin;
  const _SuccessPanel({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: RC.successSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: RC.successText.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: RC.successText.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline_rounded,
                    color: RC.successText, size: 24.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  'Link sent successfully. It may take a few minutes to arrive — check your spam folder too.',
                  style: RC
                      .body(color: RC.successText)
                      .copyWith(fontSize: 12.5.sp, height: 1.4.h),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 450.ms).scale(
            begin: const Offset(0.92, 0.92),
            end: const Offset(1, 1),
            delay: 150.ms,
            duration: 450.ms,
            curve: Curves.easeOutBack),
        SizedBox(height: 28.h),
        AuthPrimaryButton(
          label: 'Back to Sign In',
          isLoading: false,
          onPressed: onBackToLogin,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
      ],
    );
  }
}
