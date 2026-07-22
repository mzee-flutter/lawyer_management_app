import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// RightCase design tokens. Import this everywhere instead of redeclaring
/// a private `_RC` class per file — that pattern already exists in three
/// screens and will drift out of sync over time.
abstract final class RC {
  RC._();

  // Brand
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const goldLight = Color(0xFFFAEDD4);

  // Surfaces
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E1D8);

  // Text
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);

  // Semantic — danger
  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const dangerText = Color(0xFF991B1B);

  // Semantic — warning
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);
  static const warning = Color(0xFFC8952A);

  // Semantic — success
  static const successSurface = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);
  static const successText = Color(0xFF166534);

  // Semantic — info
  static const infoSurface = Color(0xFFEFF6FF);
  static const infoBorder = Color(0xFFBFDBFE);
  static const infoText = Color(0xFF1E40AF);

  // Elevation
  static BoxShadow get cardShadow => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  // Type scale — matches case_detail_info_screen_view.dart exactly
  static TextStyle display(
          {Color color = textPrimary, FontWeight weight = FontWeight.w700}) =>
      TextStyle(
          fontSize: 20.sp,
          fontWeight: weight,
          color: color,
          letterSpacing: -0.3);

  static TextStyle heading(
          {Color color = textPrimary, FontWeight weight = FontWeight.w600}) =>
      TextStyle(
          fontSize: 16.sp,
          fontWeight: weight,
          color: color,
          letterSpacing: -0.1);

  static TextStyle body({Color color = textPrimary}) =>
      TextStyle(fontSize: 14.sp, color: color, height: 1.5);

  static TextStyle caption({Color color = textSecondary}) =>
      TextStyle(fontSize: 12.sp, color: color, height: 1.4);

  static TextStyle label({Color color = textSecondary}) => TextStyle(
      fontSize: 11.sp,
      color: color,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4);
}
