import 'package:flutter/cupertino.dart';
import 'package:right_case/data/base_api_service.dart';
import 'package:right_case/data/network_api_service.dart';
import 'package:right_case/resources/URLs/auth_urls.dart';

/// Registers/refreshes the device's FCM push token with the backend.
/// Used by both LoginViewModel and RegisterViewModel right after
/// authenticating. Deliberately NOT a ChangeNotifier/ViewModel -- this is
/// silent best-effort background work with no loading state or error ever
/// shown on a screen, matching how it was already being treated where it
/// used to live (inline inside LoginRepository).
class NotificationTokenRepo {
  final BaseApiServices _services;

  NotificationTokenRepo([BaseApiServices? services])
      : _services = services ?? NetworkApiServices();

  Future<void> registerFCMToken(String userId, String token) async {
    try {
      await _services.getPostApiRequest(
        "${AuthURL.baseURl}/fcm-token",
        {"Content-Type": "application/json"},
        {"fcm_token": token},
      );
      debugPrint("✅ FCM token sent to backend");
    } catch (e) {
      debugPrint("❌ Failed to send FCM token: $e");
    }
  }

  /// Call this from the logout flow BEFORE clearing local tokens -- it
  /// needs a still-valid access token to authenticate the request. Same
  /// leak class as the SharedPreferences notification-history fix: an
  /// FCM token is bound to the device, not the session, so leaving it
  /// registered after logout means the backend could keep pushing this
  /// account's notifications to whoever uses the device next.
  Future<void> removeFCMToken() async {
    try {
      await _services.getDeleteApiRequest(
        "${AuthURL.baseURl}/fcm-token",
        {},
      );
      debugPrint("✅ FCM token removed from backend");
    } catch (e) {
      debugPrint("❌ Failed to remove FCM token: $e");
    }
  }
}
