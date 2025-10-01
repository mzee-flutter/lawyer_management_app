import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/login_user_info_view_model.dart';
import 'package:right_case/view_model/auth_view_models/login_view_model.dart';
import 'package:right_case/view_model/auth_view_models/logout_view_model.dart';
import 'package:right_case/view_model/auth_view_models/refresh_acces_token_view_model.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';
import 'package:right_case/view_model/calendar_view_model/calendar_view_model.dart';
import 'package:right_case/view_model/cases_view_model/add_case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/edit_case_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:right_case/view_model/client_view_model/client_create_view_model.dart';

import 'package:right_case/view_model/client_view_model/client_update_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';

import 'package:right_case/view_model/services/login_and_signup_view_model.dart';
import 'package:right_case/view_model/splash_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Hive.initFlutter();

  // Hive.registerAdapter(ClientModelAdapter());
  // Hive.registerAdapter(CaseModelAdapter());

  // await Hive.openBox<ClientModel>('clients');
  // await Hive.openBox<CaseModel>('cases');
  // await Hive.openBox('authBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CaseViewModel()),
            ChangeNotifierProvider(create: (_) => ClientListViewModel()),
            ChangeNotifierProvider(create: (_) => ClientCreateViewModel()),
            ChangeNotifierProvider(create: (_) => ClientUpdateViewModel()),
            ChangeNotifierProvider(create: (_) => AddCaseViewModel()),
            ChangeNotifierProvider(create: (_) => EditCaseViewModel()),
            ChangeNotifierProvider(create: (_) => LoginAndSignUpViewModel()),
            ChangeNotifierProvider(create: (_) => CalendarViewModel()),
            ChangeNotifierProvider(create: (_) => SplashViewModel()),
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
            ChangeNotifierProvider(create: (_) => RegisterViewModel()),
            ChangeNotifierProvider(
                create: (_) => RefreshAccessTokenViewModel()),
            ChangeNotifierProvider(create: (_) => LogoutViewModel()),
            ChangeNotifierProvider(create: (_) => LoginUserInfoViewModel()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
            ),
            initialRoute: RoutesName.splashScreenView,
            onGenerateRoute: Routes.generateRouts,
          ),
        );
      },
    );
  }
}
