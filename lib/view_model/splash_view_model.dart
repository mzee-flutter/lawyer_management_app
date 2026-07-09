// import 'package:all/all.dart';
// import 'package:right_case/utils/routes/notification_router.dart';
// import 'package:right_case/view/cases_screen_view/hearing_list_screen_view.dart';
// import 'package:right_case/view/home_screen_view.dart';
// import 'package:right_case/view/sign_in_screen_view.dart';
// import 'package:right_case/view_model/services/token_storage_service.dart';
//
// class SplashViewModel with ChangeNotifier {
//   final TokenStorageService _tokenStorage = TokenStorageService();
//
//   Future<void> getInitialRouting(BuildContext context) async {
//     final bool isLoggedIn = await _tokenStorage.hasValidSession();
//
//     if (!isLoggedIn) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (_) => SignInScreen()));
//       return;
//     }
//
//     if (NotificationRouter.pendingPayload != null) {
//       final payload = NotificationRouter.pendingPayload;
//
//       NotificationRouter.pendingPayload = null;
//
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => HomeScreen(),
//           ),
//         );
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => HearingListScreenView(
//               caseId: payload!.caseId,
//               hearingId: payload.hearingId,
//             ),
//           ),
//         );
//       });
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => HomeScreen(),
//           ),
//         );
//       });
//     }
//   }
// }
