import 'package:all/all.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes_names.dart';

import '../../view/calendar_view/calendar_screen_view.dart';
import '../../view/cases_screen_view/case_create_screen.dart';
import '../../view/cases_screen_view/cases_archived_list_screen.dart';
import '../../view/cases_screen_view/cases_list_screen_view.dart';
import '../../view/cases_screen_view/hearing_list_screen_view.dart';
import '../../view/client_screen_view/add_client_screen.dart';
import '../../view/client_screen_view/client_archived_list_screen.dart';
import '../../view/client_screen_view/clients_screen_view.dart';
import '../../view/court_portal_screen_view.dart';
import '../../view/forgot_password_screen_view.dart';
import '../../view/home_screen_view.dart';
import '../../view/legal_task_screen_view.dart';
import '../../view/notification_history_screen_view.dart';
import '../../view/session_error_screen.dart';
import '../../view/sign_in_screen_view.dart';
import '../../view/sign_up_screen_view.dart';
import '../../view/splash_screen_view.dart';
import '../../view_model/auth_view_models/current_user_view_model.dart';
import 'notification_router.dart';

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
        GoRoute(
          path: '/clients',
          name: RoutesName.clientsScreen,
          builder: (context, state) => const ClientsScreen(),
        ),
        GoRoute(
          path: '/clients/archived',
          name: RoutesName.archivedClientsScreen,
          builder: (context, state) => ClientArchivedListScreen(),
        ),
        GoRoute(
          path: '/clients/add',
          name: RoutesName.addClientScreen,
          builder: (context, state) => const AddClientScreen(),
        ),
        GoRoute(
          path: '/cases',
          name: RoutesName.casesListScreen,
          builder: (context, state) => const CasesListScreen(),
        ),
        GoRoute(
          path: '/cases/create',
          name: RoutesName.caseCreateScreen,
          builder: (context, state) => const CaseCreateScreen(),
        ),
        GoRoute(
          path: '/cases/archived',
          name: RoutesName.archivedCasesScreen,
          builder: (context, state) => const CasesArchivedListScreen(),
        ),
        GoRoute(
          path: '/calendar',
          name: RoutesName.calendarScreen,
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/notifications',
          name: RoutesName.notificationHistoryScreenView,
          builder: (context, state) => NotificationHistoryScreenView(),
        ),
        GoRoute(
          path: '/court-portal',
          name: RoutesName.courtPortalScreenView,
          builder: (context, state) => CourtPortalScreen(),
        ),
        GoRoute(
          path: '/legal-tasks',
          name: RoutesName.legalTaskScreenView,
          builder: (context, state) => TaskBoardScreen(),
        ),
        GoRoute(
          path: '/hearing/:caseId',
          name: 'hearing',
          builder: (context, state) => HearingListScreenView(
            caseId: state.pathParameters['caseId']!,
            hearingId: state.uri.queryParameters['hearingId'],
          ),
        ),
      ],
      errorBuilder: (context, state) {
        debugPrint('AppRouter: no match for "${state.uri}" — ${state.error}');
        return Scaffold(
            body: Center(child: Text('No route for "${state.uri}"')));
      },
    );
  }

  // app_router.dart — replace _handleAuthRedirect
  static String? _handleAuthRedirect(
      BuildContext context, GoRouterState state) {
    final status = context.read<CurrentUserViewModel>().status;
    final path = state.matchedLocation;
    debugPrint('AppRouter.redirect: status=$status path=$path '
        'pending=${NotificationRouter.pendingLocation}');

    switch (status) {
      case SessionStatus.initial:
      case SessionStatus.loading:
        // Don't drop a pending hearing target just because the session
        // check hasn't finished — hold on splash, pendingLocation survives.
        return path == '/splash' ? null : '/splash';

      case SessionStatus.unauthenticated:
        // Hearing screens require a session — a stale pending target from
        // before logout shouldn't resurrect after a future, unrelated login.
        NotificationRouter.pendingLocation = null;
        return _authFlowRoutes.contains(path) ? null : '/sign-in';

      case SessionStatus.authenticated:
        final pending = NotificationRouter.pendingLocation;
        if (pending != null) {
          NotificationRouter.pendingLocation = null;
          return pending == path ? null : pending;
        }
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
