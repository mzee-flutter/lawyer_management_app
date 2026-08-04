import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/system_design/rc_theme.dart';

/// Shown only when bootstrapSession() couldn't reach the server. Tokens may
/// still be perfectly valid, so this offers a retry instead of forcing the
/// user through sign-in again — which is what the old "error -> signUpScreen"
/// branch effectively did.
class SessionErrorScreen extends StatelessWidget {
  const SessionErrorScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.navy,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded,
                  color: RC.textOnDarkMuted, size: 48.r),
              SizedBox(height: 16.h),
              Text(
                "Couldn't reach RightCase",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: RC.textOnDark,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Check your connection and try again.',
                style: TextStyle(fontSize: 13.sp, color: RC.textOnDarkMuted),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RC.gold,
                  foregroundColor: RC.navy,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
