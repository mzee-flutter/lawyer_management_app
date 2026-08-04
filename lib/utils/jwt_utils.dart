import 'dart:convert';

import 'package:all/all.dart';

/// Decodes the `sub` (subject) claim — the user id — out of a JWT
/// WITHOUT verifying its signature.
///
/// This is safe here specifically because we only ever read back a token
/// this same app already received from its own backend and stored
/// itself — we are never trusting a token from an external source. This
/// is used purely to answer "whose on-device data is this?" for scoping
/// SharedPreferences keys, NOT as an authorization decision. Every real
/// authorization check still happens server-side, keyed off the token's
/// signature there.
///
/// Returns null for a missing/malformed/garbage token. Callers MUST
/// treat null as "no known user" and refuse to guess — never fall back
/// to a shared or default key.
///
/// NOTE: assumes your backend puts the user id under the "sub" claim
/// (the standard JWT convention, and what most FastAPI/python-jose
/// setups use). If your backend uses a different key ("user_id",
/// "userId", "id"), change the claims['sub'] lookup below.
class JwtUtils {
  static String? extractUserId(String? jwt) {
    if (jwt == null || jwt.isEmpty) return null;
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      final payload = _decodeBase64Segment(parts[1]);
      final claims = json.decode(payload);
      debugPrint('JWT claims: $claims'); // TEMP — check console, then remove
      final sub = claims['sub'] ??
          claims['user_id'] ??
          claims['id']; // widened fallback
      return sub?.toString();
    } catch (_) {
      return null;
    }
  }

  static String _decodeBase64Segment(String segment) {
    final normalized = base64Url.normalize(segment);
    return utf8.decode(base64Url.decode(normalized));
  }
}
