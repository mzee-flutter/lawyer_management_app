import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';

// ════════════════════════════════════════════════════════════════
// AuthHero — navy gradient header shared by all 3 auth screens
// ════════════════════════════════════════════════════════════════
class AuthHero extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool showBack;

  const AuthHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.balance_rounded,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 34.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [RC.navy, const Color(0xFF243356)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBack) ...[
              _BackButton(),
              SizedBox(height: 20.h),
            ],
            Center(
              child: Column(
                children: [
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: RC.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: RC.gold.withValues(alpha: 0.4),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(icon, color: RC.gold, size: 30.sp),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.4, 0.4),
                        end: const Offset(1, 1),
                        duration: 550.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RC.textOnDark,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 250.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  SizedBox(height: 6.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: RC.textOnDarkMuted,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(
                        begin: 0.3,
                        end: 0,
                        delay: 350.ms,
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            color: RC.textOnDark, size: 16.sp),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// AuthTextField — focus-aware, error-aware, obscure-toggle field
// ════════════════════════════════════════════════════════════════
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscure = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (_hasError) return RC.danger;
    if (_isFocused) return RC.navy;
    return RC.divider;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: RC.label().copyWith(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: RC.textSecondary,
              ),
        ),
        SizedBox(height: 6.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: RC.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _borderColor,
              width: (_isFocused || _hasError) ? 1.6 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: RC.navy.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onFieldSubmitted: widget.onFieldSubmitted,
            validator: (value) {
              final result = widget.validator?.call(value);
              final hasError = result != null;
              if (hasError != _hasError) {
                setState(() => _hasError = hasError);
              }
              return result;
            },
            style: TextStyle(fontSize: 14.sp, color: RC.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(color: RC.textTertiary, fontSize: 13.sp),
              prefixIcon: Icon(
                widget.icon,
                size: 18.sp,
                color: _isFocused ? RC.navy : RC.textTertiary,
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                      splashRadius: 18.r,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(scale: anim, child: child),
                        ),
                        child: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          key: ValueKey(_obscure),
                          size: 18.sp,
                          color: RC.textTertiary,
                        ),
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              errorStyle:
                  TextStyle(color: RC.danger, fontSize: 11.sp, height: 0.8),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// AuthPrimaryButton
// ════════════════════════════════════════════════════════════════
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: RC.navy,
          disabledBackgroundColor: RC.navy.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: isLoading
              ? SizedBox(
                  key: const ValueKey('loading'),
                  width: 22.w,
                  height: 22.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.4),
                )
              : Text(
                  label,
                  key: const ValueKey('label'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// AuthFooterLink
// ════════════════════════════════════════════════════════════════
class AuthFooterLink extends StatelessWidget {
  final String leading;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthFooterLink({
    super.key,
    required this.leading,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: RichText(
          text: TextSpan(
            text: leading,
            style: RC.body(color: RC.textSecondary).copyWith(fontSize: 13.5.sp),
            children: [
              TextSpan(
                text: actionLabel,
                style: TextStyle(
                    color: RC.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PasswordStrengthBar — cosmetic client-side heuristic (Sign Up only)
// ════════════════════════════════════════════════════════════════
class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[A-Za-z]').hasMatch(password)) {
      score++;
    }
    return score.clamp(0, 3);
  }

  String get _label {
    switch (_strength) {
      case 0:
        return 'Enter a password';
      case 1:
        return 'Weak password';
      case 2:
        return 'Good password';
      default:
        return 'Strong password';
    }
  }

  Color get _color {
    switch (_strength) {
      case 0:
        return RC.divider;
      case 1:
        return RC.danger;
      case 2:
        return RC.warningText;
      default:
        return RC.successText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (i) {
            final filled = i < _strength;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 5.w : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: filled ? _color : RC.divider,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 5.h),
        Text(_label,
            style: RC.caption(color: _color).copyWith(fontSize: 11.sp)),
      ],
    );
  }
}

/// Circular brand mark used on Splash, Sign In, and Sign Up.
class AuthBrandMark extends StatelessWidget {
  final double size;
  const AuthBrandMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: RC.navy,
        borderRadius: BorderRadius.circular(size.w * 0.28),
        boxShadow: [
          BoxShadow(
              color: RC.navy.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: Icon(Icons.balance_rounded, color: RC.gold, size: size.w * 0.46),
      ),
    );
  }
}
