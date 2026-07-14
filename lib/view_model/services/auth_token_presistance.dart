import 'package:right_case/view_model/services/token_storage_service.dart';

/// Single shared place that knows how to persist a fresh token pair.
/// LoginRepository, RegisterRepository, RefreshAccessTokenRepo, and
/// ChangePasswordRepo all call this instead of each duplicating the same
/// TokenStorageService.saveToken(...) call with its own local instance.
class AuthTokenPersistence {
  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required int accessTokenExpiry,
    TokenStorageService? tokenStorage,
  }) async {
    final storage = tokenStorage ?? TokenStorageService();
    await storage.saveToken(accessToken, refreshToken, accessTokenExpiry);
  }
}
