import 'dart:async';

/// Fired whenever the app must force a logout from somewhere that has no
/// BuildContext of its own (e.g. the network layer, after a refresh-token
/// failure). CurrentUserViewModel subscribes once at startup so a 401 that
/// happens ten screens deep in the app still ends the session correctly,
/// instead of leaving the user stuck with cleared tokens but a UI that
/// still thinks they're logged in.
class AuthEventBus {
  AuthEventBus._internal();
  static final AuthEventBus instance = AuthEventBus._internal();

  final StreamController<void> _forceLogoutController =
      StreamController<void>.broadcast();

  Stream<void> get onForceLogout => _forceLogoutController.stream;

  void fireForceLogout() => _forceLogoutController.add(null);

  void dispose() => _forceLogoutController.close();
}
