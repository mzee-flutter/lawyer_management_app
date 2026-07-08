import 'package:flutter/material.dart';

/// Shared color palette + style helpers for the Case Detail screen and
/// everything that hangs off it (file upload sheet, related-clients sheet).
/// Extracted from the screen file so those sheets can live in their own
/// files without duplicating these constants.
class RC {
  static const navy = Color(0xFF1A2744);
  static const navyLight = Color(0xFF243356);
  static const gold = Color(0xFFC8952A);
  static const goldLight = Color(0xFFFAEDD4);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);
  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const successText = Color(0xFF166534);
  static const successSurface = Color(0xFFF0FDF4);
  static const infoText = Color(0xFF1E40AF);
  static const infoSurface = Color(0xFFEFF6FF);
  static const warningText = Color(0xFF92400E);
  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  static Color statusColor(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'running':
        return infoText;
      case 'decided':
        return successText;
      case 'abandoned':
      case 'cancelled':
        return danger;
      case 'pending':
      case 'date awaited':
        return warningText;
      default:
        return navy;
    }
  }

  static Color statusSurface(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'running':
        return infoSurface;
      case 'decided':
        return successSurface;
      case 'abandoned':
      case 'cancelled':
        return dangerSurface;
      case 'pending':
      case 'date awaited':
        return warningSurface;
      default:
        return navy.withValues(alpha: 0.08);
    }
  }
}
