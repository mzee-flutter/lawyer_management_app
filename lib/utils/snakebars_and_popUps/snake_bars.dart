import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/system_design/rc_theme.dart';

enum SnackType { success, error, warning, info }

class SnakeBars {
  SnakeBars._();

  // ── Backward-compatible entry points ─────────────────────────────
  // Signatures preserved exactly so no existing call site across the
  // app needs to change. All three now render the same premium widget;
  // only the default `type` differs to match each method's old intent.

  static void flutterToast(String message, BuildContext context,
      {SnackType? type}) {
    _show(context, message, type ?? _inferType(message));
  }

  static void flutterFlashBar(String message, BuildContext context,
      {SnackType? type}) {
    _show(context, message, type ?? SnackType.error);
  }

  static void scaffoldMessenger(String message, BuildContext context,
      {SnackType? type}) {
    _show(context, message, type ?? _inferType(message));
  }

  // ── Heuristic — infers intent from message text so existing call
  // sites ("Case created successfully", "Failed to update") get sane
  // colours without needing to be touched. ─────────────────────────
  static SnackType _inferType(String message) {
    final m = message.toLowerCase();
    const errorWords = [
      'fail',
      'error',
      'invalid',
      'could not',
      'unable',
      'denied'
    ];
    const successWords = [
      'success',
      'added',
      'created',
      'updated',
      'removed',
      'deleted',
      'refreshed',
      'sent',
      'saved'
    ];
    const warningWords = ['please', 'required', 'select', 'warning'];

    if (errorWords.any(m.contains)) return SnackType.error;
    if (successWords.any(m.contains)) return SnackType.success;
    if (warningWords.any(m.contains)) return SnackType.warning;
    return SnackType.info;
  }

  static ({Color color, IconData icon}) _visualFor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return (
          color: RC.successText,
          icon: Icons.check_circle_outline_rounded
        );
      case SnackType.error:
        return (color: RC.danger, icon: Icons.error_outline_rounded);
      case SnackType.warning:
        return (color: RC.warningText, icon: Icons.warning_amber_rounded);
      case SnackType.info:
        return (color: RC.infoText, icon: Icons.info_outline_rounded);
    }
  }

  static void _show(BuildContext context, String message, SnackType type) {
    final visual = _visualFor(type);
    final messenger = ScaffoldMessenger.of(context);

    HapticFeedback.lightImpact();
    messenger.hideCurrentSnackBar(); // prevents stacking spam on rapid actions

    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: type == SnackType.error ? 4 : 3),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        padding: EdgeInsets.zero,
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: RC.navy,
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                    color: visual.color.withValues(alpha: 0.18),
                    shape: BoxShape.circle),
                child: Icon(visual.icon, size: 16.sp, color: visual.color),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: RC.textOnDark,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
