import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/notification_payload.dart';
import 'package:right_case/models/stored_notification_model.dart';
import 'package:right_case/utils/jwt_utils.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
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
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/court_portal_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_delete_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_list_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/hearing_update_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/legal_task_view_model.dart';
import 'package:right_case/view_model/cases_view_model/hearing_create_view_model/today_and_upcoming_hearing_view_model.dart';
import 'package:right_case/view_model/cases_view_model/single_case_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_archive_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_archived_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_create_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_list_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_permanent_delete_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_restore_view_model.dart';
import 'package:right_case/view_model/client_view_model/client_update_view_model.dart';
import 'package:right_case/view_model/services/firebase_notification_service.dart';
import 'package:right_case/view_model/services/notification_history_view_model.dart';
import 'package:right_case/view_model/services/notification_storage_service.dart';
import 'package:right_case/view_model/services/token_storage_service.dart';

import 'utils/routes/app_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final notification = message.notification;
  if (notification == null) return;

  // Background isolate: no widget tree, no Provider, no BuildContext —
  // CurrentUserViewModel is unreachable here. TokenStorageService reads
  // from on-device storage via platform channels, which DOES work in a
  // background isolate, so it's the only reliable way to know who's
  // logged in right now.
  final tokenStorage = TokenStorageService();
  final accessToken = await tokenStorage.getAccessToken();
  final userId = JwtUtils.extractUserId(accessToken);

  if (userId == null) {
    // No attributable owner — dropping is correct. Storing under no
    // owner, or guessing one, is exactly the leak this fix prevents.
    debugPrint('Background notification dropped: no active session.');
    return;
  }

  await NotificationStorageService.saveNotification(
    StoredNotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? '',
      body: notification.body ?? '',
      payload: NotificationPayload.fromMap(message.data),
      timestamp: DateTime.now(),
    ),
    userId,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  // One-time cleanup: discard anything saved under the old, unscoped key
  // from before this fix — it has no reliable single owner.
  await NotificationStorageService.migrateLegacyDataIfNeeded();

  final currentUserViewModel = CurrentUserViewModel();
  AppRouter.init(currentUserViewModel);
  await FirebaseNotificationService().init();

  unawaited(currentUserViewModel.bootstrapSession());

  runApp(MyApp(currentUserViewModel: currentUserViewModel));
}

class MyApp extends StatelessWidget {
  final CurrentUserViewModel currentUserViewModel;
  const MyApp({super.key, required this.currentUserViewModel});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider<CurrentUserViewModel>.value(
              value: currentUserViewModel),
          ChangeNotifierProvider(create: (_) => CaseListViewModel()),
          ChangeNotifierProvider(create: (_) => ClientListViewModel()),
          ChangeNotifierProvider(create: (_) => ClientCreateViewModel()),
          ChangeNotifierProvider(create: (_) => ClientUpdateViewModel()),
          ChangeNotifierProvider(create: (_) => CaseCreateViewModel()),
          ChangeNotifierProvider(create: (_) => CaseUpdateViewModel()),
          ChangeNotifierProvider(create: (_) => CalendarViewModel()),
          ChangeNotifierProxyProvider<CurrentUserViewModel, LoginViewModel>(
            create: (ctx) => LoginViewModel(ctx.read<CurrentUserViewModel>()),
            update: (ctx, currentUserVM, previous) =>
                previous ?? LoginViewModel(currentUserVM),
          ),
          ChangeNotifierProxyProvider<CurrentUserViewModel, RegisterViewModel>(
              create: (ctx) =>
                  RegisterViewModel(ctx.read<CurrentUserViewModel>()),
              update: (ctx, currentUserVM, previous) =>
                  previous ?? RegisterViewModel(currentUserVM)),
          ChangeNotifierProvider(create: (_) => RefreshAccessTokenViewModel()),
          // 2. Notification state (Proxy provider that listens to CurrentUserViewModel)
          ChangeNotifierProxyProvider<CurrentUserViewModel,
              NotificationHistoryViewModel>(
            create: (context) => NotificationHistoryViewModel(),
            update: (context, currentUserVM, previous) {
              final notificationVM = previous ?? NotificationHistoryViewModel();

              // CRITICAL FIX: If a user is logged in, bind their ID to the notification VM
              if (currentUserVM.isAuthenticated && currentUserVM.user != null) {
                // Replace 'id' with your actual User model's unique identifier property
                notificationVM.bindUser(currentUserVM.user!.id);
              }

              return notificationVM;
            },
          ),
          // 3. Finally, provide LogoutViewModel using ProxyProvider2 because it has TWO dependencies
          // 3. Logout state (Listens to both)
          ChangeNotifierProxyProvider2<CurrentUserViewModel,
              NotificationHistoryViewModel, LogoutViewModel>(
            create: (context) => LogoutViewModel(
              context.read<CurrentUserViewModel>(),
              context.read<NotificationHistoryViewModel>(),
            ),
            update: (context, currentUserVM, notificationVM, previous) {
              // If the view model already exists, update its dependencies and preserve it!
              if (previous != null) {
                previous.updateDependencies(currentUserVM, notificationVM);
                return previous;
              }

              // Only instantiate a brand new one on the very first creation
              return LogoutViewModel(currentUserVM, notificationVM);
            },
          ),
          ChangeNotifierProvider(create: (_) => ClientArchiveViewModel()),
          ChangeNotifierProvider(
              create: (_) => ClientPermanentDeleteViewModel()),
          ChangeNotifierProvider(create: (_) => ClientArchivedListViewModel()),
          ChangeNotifierProvider(create: (_) => ClientRestoreViewModel()),
          ChangeNotifierProvider(create: (_) => CaseTypeViewModel()),
          ChangeNotifierProvider(create: (_) => CaseStageViewModel()),
          ChangeNotifierProvider(create: (_) => CaseStatusViewModel()),
          ChangeNotifierProvider(create: (_) => CourtTypeViewModel()),
          ChangeNotifierProvider(create: (_) => CaseArchiveViewModel()),
          ChangeNotifierProvider(create: (_) => CasePermanentDeleteViewModel()),
          ChangeNotifierProvider(create: (_) => CaseArchivedListViewModel()),
          ChangeNotifierProvider(create: (_) => CaseRestoreViewModel()),
          ChangeNotifierProvider(create: (_) => HearingListViewModel()),
          ChangeNotifierProvider(create: (_) => HearingDeleteViewModel()),
          ChangeNotifierProvider(create: (_) => HearingCreateViewModel()),
          ChangeNotifierProvider(create: (_) => HearingUpdateViewModel()),
          ChangeNotifierProvider(create: (_) => SingleCaseViewModel()),

          ChangeNotifierProvider(create: (_) => AgendaViewModel()),
          ChangeNotifierProvider(create: (_) => CourtPortalViewModel()),
          ChangeNotifierProvider(create: (_) => LegalTaskViewModel()),
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

///file upload issue that should be solved...(Done)
///notification navigation from terminated app state should be working perfectly...(Done)
///and the last two things is Delete Account setup for both frontend and backend...(Done)
///and change password or forgot password functionality should be included in the app...(Done)
///and the last is rechecking and understanding the refreshToken use to get the new accessToken (The automatic call)...(Done)
///Making the sign-in and sign-up and some forgot-password pages should be informative responsive on different errors(Done)

///------------------------------------------------///
///Tomorrow Todo:
///first check the hearing is created or not(Done)
///then confirm that we get the notification or not from that we can analyze that we get fcm token or not(Done)
///and also solving the notifications that are disappeared....(Done)
///confirming the delete account works perfectly(Done)
///and also look for the data leak across different accounts and user(Done)
///
///-------------------------------------------///
