import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_model.dart';
import 'package:right_case/models/client_model.dart';
import 'package:right_case/utils/routes/routes.dart';
import 'package:right_case/utils/routes/routes_names.dart';

import 'package:right_case/view_model/add_client_view_model.dart';
import 'package:right_case/view_model/calendar_view_model/calendar_view_model.dart';
import 'package:right_case/view_model/cases_view_model/add_case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_view_model.dart';
import 'package:right_case/view_model/cases_view_model/edit_case_view_model.dart';
import 'package:right_case/view_model/client_edit_view_model.dart';
import 'package:right_case/view_model/client_view_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:right_case/view_model/services/login_and_signup_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Hive.initFlutter();

  Hive.registerAdapter(ClientModelAdapter());
  Hive.registerAdapter(CaseModelAdapter());

  await Hive.openBox<ClientModel>('clients');
  await Hive.openBox<CaseModel>('cases');
  await Hive.openBox('authBox');

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
            ChangeNotifierProvider(create: (_) => ClientViewModel()),
            ChangeNotifierProvider(create: (_) => AddClientViewModel()),
            ChangeNotifierProvider(create: (_) => ClientEditViewModel()),
            ChangeNotifierProvider(create: (_) => AddCaseViewModel()),
            ChangeNotifierProvider(create: (_) => EditCaseViewModel()),
            ChangeNotifierProvider(create: (_) => LoginAndSignUpViewModel()),
            ChangeNotifierProvider(create: (_) => CalendarViewModel()),
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
