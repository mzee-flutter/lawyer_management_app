import 'package:all/all.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes_names.dart';

import '../../view/forgot_password_screen_view.dart';
import '../../view/home_screen_view.dart';
import '../../view/session_error_screen.dart';
import '../../view/sign_in_screen_view.dart';
import '../../view/sign_up_screen_view.dart';
import '../../view/splash_screen_view.dart';
import '../../view_model/auth_view_models/current_user_view_model.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static late final GoRouter router;

  // Screens reachable while logged out. Not just sign-in — sign-up and
  // forgot-password have to be on this list too, or a user tapping
  // "create account" gets redirected straight back to sign-in.
  static const _authFlowRoutes = {'/sign-in', '/sign-up', '/forgot-password'};

  /// Called once in main(), after currentUserViewModel exists, before runApp.
  static void init(CurrentUserViewModel currentUserViewModel) {
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      // Re-runs `redirect` any time CurrentUserViewModel calls
      // notifyListeners() — login, logout, a 401 via AuthEventBus,
      // bootstrapSession() resolving. This is the piece that replaces
      // AuthGate's context.watch().
      refreshListenable: currentUserViewModel,
      redirect: _handleAuthRedirect,
      routes: [
        GoRoute(
          path: '/splash',
          name: RoutesName.splashScreenView,
          builder: (context, state) => const SplashScreenView(),
        ),
        GoRoute(
          path: '/session-error',
          name: 'sessionError',
          builder: (context, state) => SessionErrorScreen(
            onRetry: () =>
                context.read<CurrentUserViewModel>().bootstrapSession(),
          ),
        ),
        GoRoute(
          path: '/sign-in',
          name: RoutesName.signInScreen,
          builder: (context, state) => SignInScreen(),
        ),
        GoRoute(
          path: '/sign-up',
          name: RoutesName.signUpScreen,
          builder: (context, state) => SignUpScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          name: RoutesName.forgotPasswordScreen,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          name: RoutesName.homeScreen,
          builder: (context, state) => const HomeScreen(),
        ),
        // ... every other GoRoute from the previous message stays exactly
        // as-is: clients, cases, calendar, notifications, court-portal,
        // legal-tasks, hearing/:caseId ...
      ],
      errorBuilder: (context, state) {
        debugPrint('AppRouter: no match for "${state.uri}" — ${state.error}');
        return Scaffold(
            body: Center(child: Text('No route for "${state.uri}"')));
      },
    );
  }

  static String? _handleAuthRedirect(
      BuildContext context, GoRouterState state) {
    final status = context.read<CurrentUserViewModel>().status;
    final path = state.matchedLocation;

    switch (status) {
      case SessionStatus.initial:
      case SessionStatus.loading:
        return path == '/splash' ? null : '/splash';

      case SessionStatus.unauthenticated:
        return _authFlowRoutes.contains(path) ? null : '/sign-in';

      case SessionStatus.authenticated:
        // Only pull the user off splash/auth/error screens. Anywhere else
        // — /home, /cases, /hearing/:caseId from a notification deep
        // link — is left alone.
        if (path == '/splash' ||
            path == '/session-error' ||
            _authFlowRoutes.contains(path)) {
          return '/home';
        }
        return null;

      case SessionStatus.error:
        return path == '/session-error' ? null : '/session-error';
    }
  }
}
