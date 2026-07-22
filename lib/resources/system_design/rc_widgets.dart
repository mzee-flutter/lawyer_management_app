import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'rc_theme.dart';

/// Compact colored status pill. Pass the semantic color pair your screen
/// computes (case status, hearing status, etc.) — this widget only renders.
class RCStatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color surface;
  final double? fontSize;

  const RCStatusPill({
    super.key,
    required this.label,
    required this.color,
    required this.surface,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.5.h),
      decoration: BoxDecoration(
          color: surface, borderRadius: BorderRadius.circular(20.r)),
      child: Text(
        label,
        style: TextStyle(
            fontSize: fontSize ?? 10.5.sp,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}

/// Standard empty-state block: icon in a gold circle, title, message.
class RCEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const RCEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: RC.navy.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32.sp,
                color: RC.navy.withValues(alpha: 0.4),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text(title, style: RC.heading())
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              message,
              style: RC.body(color: RC.textSecondary),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

/// Error-state block: same shape as RCEmptyState, but for real fetch
/// failures (network/server), never for "list is legitimately empty."
/// Danger colors are kept local rather than pulled from RC because the
/// shared theme doesn't define danger tokens yet -- if/when you add
/// RC.danger / RC.dangerSurface to rc_theme.dart, swap these three
/// constants for the real tokens (same hex values, so nothing shifts).

class RCErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const RCErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Couldn\'t load this',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: RC.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                color: RC.danger,
                size: 32.sp,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: RC.textPrimary,
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: RC.textSecondary,
                height: 1.4,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: RC.navy,
                backgroundColor: RC.navy.withValues(alpha: 0.06),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

/// Reusable destructive-confirmation dialog. Used by file delete and
/// hearing delete so both look identical and neither reimplements dialog
/// chrome. `onConfirm` runs AFTER the dialog is popped, so it's always
/// safe to update state or show a toast inside it.
class RCConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final Color confirmSurface;
  final Color? confirmBorder;
  final String cancelLabel;
  final Future<void> Function() onConfirm;

  const RCConfirmDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconSurface,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
    required this.confirmSurface,
    this.confirmBorder,
    this.cancelLabel = 'Cancel',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconSurface,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Color confirmSurface,
    Color? confirmBorder,
    String cancelLabel = 'Cancel',
    required Future<void> Function() onConfirm,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => RCConfirmDialog(
        icon: icon,
        iconColor: iconColor,
        iconSurface: iconSurface,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        confirmColor: confirmColor,
        confirmSurface: confirmSurface,
        confirmBorder: confirmBorder,
        cancelLabel: cancelLabel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: RC.surface,
      surfaceTintColor: RC.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.w,
            height: 56.h,
            decoration:
                BoxDecoration(color: iconSurface, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 26.sp),
          ),
          SizedBox(height: 16.h),
          Text(title, style: RC.heading()),
          SizedBox(height: 8.h),
          Text(message,
              textAlign: TextAlign.center,
              style: RC.body(color: RC.textSecondary)),
          SizedBox(height: 22.h),
          Row(
            children: [
              Expanded(
                child: _RCDialogButton(
                  label: cancelLabel,
                  background: RC.background,
                  textColor: RC.textPrimary,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _RCDialogButton(
                  label: confirmLabel,
                  background: confirmSurface,
                  textColor: confirmColor,
                  border: confirmBorder,
                  onTap: () async {
                    Navigator.pop(context);
                    await onConfirm();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RCDialogButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final Color? border;
  final VoidCallback onTap;

  const _RCDialogButton({
    required this.label,
    required this.background,
    required this.textColor,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 46.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: border != null ? Border.all(color: border!) : null,
          ),
          child: Text(
            label,
            style: TextStyle(
                color: textColor, fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
