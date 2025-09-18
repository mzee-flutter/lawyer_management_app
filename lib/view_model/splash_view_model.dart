import 'package:flutter/cupertino.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

class SplashViewModel with ChangeNotifier {
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<void> getInitialRoute(context) async {
    final hasSession = await _tokenStorage.hasValidSession();
    // final accessToken = await _tokenStorage.getAccessToken();
    // final expiry = await _tokenStorage.getAccessTokenExpiry();
    // print("accessToken: $accessToken");
    // print("expiry: $expiry");
    // print("now: ${DateTime.now().millisecondsSinceEpoch}");
    // print("valid Session: $hasSession");

    await Future.delayed(Duration(seconds: 3));

    if (hasSession) {
      Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
    } else {
      Navigator.pushReplacementNamed(context, RoutesName.signInScreen);
    }
  }
}
