import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../resources/system_design/auth_widgets.dart';
import '../resources/system_design/rc_theme.dart';

/// Pure brand animation — no lifecycle, no session checks, no navigation.
/// AuthGate decides when this is on screen and when to swap it out; this
/// widget doesn't need to know why, which is exactly what makes it safe to
/// reuse or restyle without touching auth logic ever again.
class SplashScreenView extends StatelessWidget {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RC.navy,
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.15),
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  RC.gold.withValues(alpha: 0.16),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthBrandMark(size: 88)
                    .animate()
                    .scale(
                        begin: const Offset(0.7, 0.7),
                        end: const Offset(1, 1),
                        duration: 700.ms,
                        curve: Curves.easeOutBack)
                    .fadeIn(duration: 500.ms)
                    .then(delay: 200.ms)
                    .shimmer(
                        duration: 1400.ms,
                        color: Colors.white.withValues(alpha: 0.35)),
                SizedBox(height: 24.h),
                Text(
                  'RightCase',
                  style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: RC.textOnDark,
                      letterSpacing: 0.5),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
                SizedBox(height: 6.h),
                Text(
                  'Legal case management, simplified',
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: RC.textOnDarkMuted,
                      letterSpacing: 0.2),
                ).animate().fadeIn(delay: 650.ms, duration: 500.ms),
              ],
            ),
          ),
          Positioned(
            bottom: 56.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 28.r,
                height: 28.r,
                child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(RC.gold)),
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}
