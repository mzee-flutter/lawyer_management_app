import 'package:flutter/material.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view/calendar_view/calendar_screen_view.dart';
import 'package:right_case/view/cases_screen_view/case_create_screen.dart';
import 'package:right_case/view/cases_screen_view/cases_list_screen_view.dart';
import 'package:right_case/view/client_screen_view/add_client_screen.dart';
import 'package:right_case/view/client_screen_view/client_archived_list_screen.dart';
import 'package:right_case/view/client_screen_view/clients_screen_view.dart';
import 'package:right_case/view/forgot_password_screen_view.dart';
import 'package:right_case/view/home_screen_view.dart';
import 'package:right_case/view/sign_in_screen_view.dart';
import 'package:right_case/view/sign_up_screen_view.dart';
import 'package:right_case/view/splash_screen_view.dart';

class Routes {
  static MaterialPageRoute generateRouts(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.signInScreen:
        return MaterialPageRoute(builder: (_) => SignInScreen());

      case RoutesName.signUpScreen:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case RoutesName.splashScreenView:
        return MaterialPageRoute(builder: (_) => const SplashScreenView());

      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RoutesName.clientsScreen:
        return MaterialPageRoute(builder: (_) => const ClientsScreen());

      case RoutesName.archivedClientsScreen:
        return MaterialPageRoute(builder: (_) => ClientArchivedListScreen());
      case RoutesName.forgotPasswordScreen:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case RoutesName.addClientScreen:
        return MaterialPageRoute(builder: (_) => const AddClientScreen());

      case RoutesName.casesListScreen:
        return MaterialPageRoute(builder: (_) => const CasesListScreen());

      case RoutesName.caseCreateScreen:
        return MaterialPageRoute(builder: (_) => const CaseCreateScreen());

      case RoutesName.calendarScreen:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Text('No routes to this page!'),
          ),
        );
    }
  }
}
