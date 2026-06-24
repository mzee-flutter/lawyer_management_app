import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/notification_payload.dart';
import 'package:right_case/models/stored_notification_model.dart';
import 'package:right_case/utils/navigation/navigation_service.dart';
import 'package:right_case/utils/routes/routes.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/login_user_info_view_model.dart';
import 'package:right_case/view_model/auth_view_models/login_view_model.dart';
import 'package:right_case/view_model/auth_view_models/logout_view_model.dart';
import 'package:right_case/view_model/auth_view_models/refresh_acces_token_view_model.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';
import 'package:right_case/view_model/calendar_view_model/calendar_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_archive_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_archived_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_permanent_delete_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_restore_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_stage_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_status_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_update_view_model.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_delete_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_update_view_model.dart';
import 'package:right_case/view_model/cases_view_model/single_case_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_archive_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_create_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_permanent_delete_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_restore_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_update_view_model.dart';
import 'package:right_case/view_model/services/firebase_notification_service.dart';
import 'package:right_case/view_model/services/login_and_signup_view_model.dart';
import 'package:right_case/view_model/services/notification_history_view_model.dart';
import 'package:right_case/view_model/services/notification_storage_service.dart';
import 'package:right_case/view_model/splash_view_model.dart';

@pragma('vm:entry-print')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification != null) {
    final payload = NotificationPayload.fromMap(message.data);
    final localNotification = StoredNotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? "",
      body: notification.body ?? "",
      payload: payload,
      timestamp: DateTime.now(),
    );
    await NotificationStorageService.saveNotification(localNotification);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseNotificationService().init();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => CaseListViewModel()),
            ChangeNotifierProvider(create: (_) => ClientListViewModel()),
            ChangeNotifierProvider(create: (_) => ClientCreateViewModel()),
            ChangeNotifierProvider(create: (_) => ClientUpdateViewModel()),
            ChangeNotifierProvider(create: (_) => CaseCreateViewModel()),
            ChangeNotifierProvider(create: (_) => CaseUpdateViewModel()),
            ChangeNotifierProvider(create: (_) => LoginAndSignUpViewModel()),
            ChangeNotifierProvider(create: (_) => CalendarViewModel()),
            ChangeNotifierProvider(create: (_) => SplashViewModel()),
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
            ChangeNotifierProvider(create: (_) => RegisterViewModel()),
            ChangeNotifierProvider(
                create: (_) => RefreshAccessTokenViewModel()),
            ChangeNotifierProvider(create: (_) => LogoutViewModel()),
            ChangeNotifierProvider(create: (_) => LoginUserInfoViewModel()),
            ChangeNotifierProvider(create: (_) => ClientArchiveViewModel()),
            ChangeNotifierProvider(
                create: (_) => ClientPermanentDeleteViewModel()),
            ChangeNotifierProvider(
                create: (_) => ClientArchivedListViewModel()),
            ChangeNotifierProvider(create: (_) => ClientRestoreViewModel()),
            ChangeNotifierProvider(create: (_) => CaseTypeViewModel()),
            ChangeNotifierProvider(create: (_) => CaseStageViewModel()),
            ChangeNotifierProvider(create: (_) => CaseStatusViewModel()),
            ChangeNotifierProvider(create: (_) => CourtTypeViewModel()),
            ChangeNotifierProvider(create: (_) => CaseArchiveViewModel()),
            ChangeNotifierProvider(
                create: (_) => CasePermanentDeleteViewModel()),
            ChangeNotifierProvider(create: (_) => CaseArchivedListViewModel()),
            ChangeNotifierProvider(create: (_) => CaseRestoreViewModel()),
            ChangeNotifierProvider(create: (_) => HearingListViewModel()),
            ChangeNotifierProvider(create: (_) => HearingDeleteViewModel()),
            ChangeNotifierProvider(create: (_) => HearingCreateViewModel()),
            ChangeNotifierProvider(create: (_) => HearingUpdateViewModel()),
            ChangeNotifierProvider(create: (_) => SingleCaseViewModel()),
            ChangeNotifierProvider(
              create: (_) => NotificationHistoryViewModel(),
            ),
          ],
          child: MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
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
