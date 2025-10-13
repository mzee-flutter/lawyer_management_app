import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = "access_token";
  static const String _refreshTokenKey = "refresh_token";
  static const String _accessTokenExpiryKey = "access_token_expiry";

  /// Save tokens with expiry datetime
  Future<void> saveToken(
    String accessToken,
    String refreshToken,
    int expireAt,
  ) async {
    final expiryMs = expireAt * 1000;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _accessTokenExpiryKey,
      value: expiryMs.toString(),
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<int?> getAccessTokenExpiry() async {
    final expiryStr = await _storage.read(key: _accessTokenExpiryKey);
    return expiryStr != null ? int.tryParse(expiryStr) : null;
  }

  /// Returns true if the access token is expired
  Future<bool> isAccessTokenExpired() async {
    final expiry = await getAccessTokenExpiry();
    if (expiry == null) return true;

    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  Future<bool> hasValidSession() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    if (accessToken == null || refreshToken == null) return false;

    final expired = await isAccessTokenExpired();
    return !expired;
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _accessTokenExpiryKey);
  }
}
