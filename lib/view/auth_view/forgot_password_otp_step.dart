import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';

import '../../view_model/auth_view_models/forgot_password_view_model.dart';
import 'otp_input_field.dart';

class ForgotPasswordOtpStep extends StatefulWidget {
  final VoidCallback onSuccess;

  const ForgotPasswordOtpStep({super.key, required this.onSuccess});

  @override
  State<ForgotPasswordOtpStep> createState() => _ForgotPasswordOtpStepState();
}

class _ForgotPasswordOtpStepState extends State<ForgotPasswordOtpStep> {
  // The one piece of state that legitimately stays in the View. Clearing
  // the six OTP boxes after a failed attempt is an imperative action on a
  // child widget's own ephemeral TextEditingControllers -- there's nothing
  // for a ChangeNotifier to "own" here, so a GlobalKey is the correct tool,
  // not a workaround. Everything else (cooldown, error flag, timer) now
  // lives in ForgotPasswordViewModel -- there is no setState() call
  // anywhere in this class.
  final _otpFieldKey = GlobalKey<OtpInputFieldState>();

  Future<void> _onOtpCompleted(
      ForgotPasswordViewModel viewModel, String otp) async {
    final result = await viewModel.verifyOtp(otp);
    if (!mounted) return;

    SnakeBars.flutterToast(result.message, context);

    if (result.success) {
      widget.onSuccess();
    } else {
      // viewModel.otpHasError is already true at this point (set inside
      // verifyOtp), which drives the red border via context.watch below.
      // This clear() is purely about wiping the entered digits so the
      // user can retype -- it doesn't need to touch the VM.
      _otpFieldKey.currentState?.clear();
    }
  }

  Future<void> _resend(ForgotPasswordViewModel viewModel) async {
    if (!viewModel.canResendOtp) return; // belt-and-suspenders; button is
    // already disabled via onPressed below when this is false.
    final result = await viewModel.resendOtp();
    if (!mounted) return;
    SnakeBars.flutterToast(result.message, context);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ForgotPasswordViewModel>();
    final email = viewModel.email ?? '';
    final cooldown = viewModel.resendCooldown;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            "Enter the code",
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: RC.navy,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "We sent a 6-digit code to $email. It expires in 10 minutes.",
            style: TextStyle(
              fontSize: 14.sp,
              color: RC.textSecondary,
              // Was 1.4.h -- TextStyle.height is a unitless line-height
              // multiplier, not a physical dimension, so running it
              // through ScreenUtil's .h scaling was corrupting it.
              height: 1.4,
            ),
          ),
          SizedBox(height: 32.h),
          OtpInputField(
            key: _otpFieldKey,
            hasError: viewModel.otpHasError,
            onCompleted: (otp) => _onOtpCompleted(viewModel, otp),
          ),
          SizedBox(height: 20.h),
          if (viewModel.isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4.w,
                    valueColor: AlwaysStoppedAnimation<Color>(RC.navy),
                  ),
                ),
              ),
            ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton(
              onPressed:
                  viewModel.canResendOtp ? () => _resend(viewModel) : null,
              child: Text(
                cooldown > 0 ? "Resend code in ${cooldown}s" : "Resend code",
                style: TextStyle(
                  color: cooldown > 0 ? RC.textSecondary : RC.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
