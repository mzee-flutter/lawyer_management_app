// lib/view/drawer_view.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/auth_view_models/current_user_view_model.dart';
import 'package:right_case/view_model/auth_view_models/logout_view_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/network_api_service.dart';
import '../repository/auth_repository/detele_account_repo.dart';
import '../resources/system_design/rc_theme.dart';
import '../resources/system_design/rc_widgets.dart';
import '../view_model/auth_view_models/delete_account_view_model.dart';
import '../view_model/services/notification_history_view_model.dart';

// ════════════════════════════════════════════════════════════════
// CONFIGURATION — every placeholder value lives here, in one place.
// Update these before shipping. Nothing else in this file needs edits.
// ════════════════════════════════════════════════════════════════
class _DrawerConfig {
  static const String supportWhatsappNumber =
      '1234567890'; // country code, no '+'
  static const String supportEmail = 'support@rightcase.com';
  static const String websiteUrl = 'https://yourwebsite.com';
  static const String privacyPolicyUrl = 'https://yourwebsite.com/privacy';
  static const String termsOfServiceUrl = 'https://yourwebsite.com/terms';
  static const String helpCenterUrl = 'https://yourwebsite.com/help';
  static const String androidPackageId = 'com.yourcompany.rightcase';
  static const String iosAppStoreId = '0000000000'; // numeric App Store ID
  static const String appVersion = '1.0.0'; // wire package_info_plus if added
  static const String appBuildNumber = '1';
}

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  // ── Launch helpers ────────────────────────────────────────────

  Future<void> _launchUrl(BuildContext context, String urlString,
      {String? failMessage}) async {
    final uri = Uri.parse(urlString);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        SnakeBars.flutterToast(
            failMessage ?? 'Could not open this link', context,
            type: SnackType.error);
      }
    } catch (_) {
      if (context.mounted) {
        SnakeBars.flutterToast(
            failMessage ?? 'Could not open this link', context,
            type: SnackType.error);
      }
    }
  }

  // wa.me works via the app OR a browser fallback — far more reliable
  // than the whatsapp:// scheme, which Android 11+ package-visibility
  // rules frequently block from `canLaunchUrl` even when installed.
  void _contactWhatsApp(BuildContext context) {
    final message =
        Uri.encodeComponent('Hello Right Case Support, I need some help.');
    _launchUrl(
      context,
      'https://wa.me/${_DrawerConfig.supportWhatsappNumber}?text=$message',
      failMessage: 'WhatsApp is not available on this device',
    );
  }

  void _contactEmail(BuildContext context) {
    final subject = Uri.encodeComponent('App Support Inquiry');
    _launchUrl(
      context,
      'mailto:${_DrawerConfig.supportEmail}?subject=$subject',
      failMessage: 'No email app found on this device',
    );
  }

  void _openStoreListing(BuildContext context) {
    final url = Platform.isIOS
        ? 'https://apps.apple.com/app/id${_DrawerConfig.iosAppStoreId}'
        : 'https://play.google.com/store/apps/details?id=${_DrawerConfig.androidPackageId}';
    _launchUrl(context, url, failMessage: 'Could not open the app store');
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out Right Case, the best app for managing your legal workspace! '
            'Download here: ${_DrawerConfig.websiteUrl}/download',
        subject: 'Right Case App',
      ),
    );
  }

  // ── Header profile preview ───────────────────────────────────

  void _showProfilePreview(BuildContext context,
      {required String name, required String email, required String initial}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) =>
          _ProfilePreviewSheet(name: name, email: email, initial: initial),
    );
  }

  // ── Logout confirmation ───────────────────────────────────────

  void _confirmLogout(BuildContext context, LogoutViewModel logoutVM) {
    RCConfirmDialog.show(
      context: context,
      icon: Icons.logout_rounded,
      iconColor: RC.navy,
      iconSurface: RC.navy.withValues(alpha: 0.08),
      title: 'Log out?',
      message:
          "You'll need to sign in again to access your cases, clients, and hearings.",
      confirmLabel: 'Log out',
      confirmColor: RC.navy,
      confirmSurface: RC.navy.withValues(alpha: 0.08),
      confirmBorder: RC.navy.withValues(alpha: 0.2),
      onConfirm: () async => logoutVM.logoutUser(),
    );
  }

// ── Delete account — type-to-confirm irreversible action ─────

  void _showDeleteAccountSheet(BuildContext context) {
    // Captured from the ambient Provider tree before opening the sheet --
    // assumes both CurrentUserViewModel and NotificationHistoryViewModel are
    // already provided somewhere above this screen (they should be, as
    // app-wide singletons), so no new provider setup is needed elsewhere.
    final currentUserVM = context.read<CurrentUserViewModel>();
    final notificationHistoryVM = context.read<NotificationHistoryViewModel>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ChangeNotifierProvider(
        create: (_) => DeleteAccountViewModel(
          deleteAccountRepo: DeleteAccountRepo(NetworkApiServices()),
          currentUserVM: currentUserVM,
          notificationHistoryVM: notificationHistoryVM,
        ),
        child: const _DeleteAccountSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoutVM = context.watch<LogoutViewModel>();

    return Drawer(
      backgroundColor: RC.background,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 8.h),
                      _SectionTitle('WORKSPACE'),
                      _DrawerItem(
                        icon: Icons.archive_rounded,
                        title: 'Archived Clients',
                        subtitle: 'Restore clients from here',
                        iconColor: RC.navy,
                        onTap: () =>
                            context.pushNamed(RoutesName.archivedClientsScreen),
                      ),
                      _DrawerItem(
                        icon: Icons.cases_rounded,
                        title: 'Archived Cases',
                        subtitle: 'Restore cases from here',
                        iconColor: RC.navy,
                        onTap: () =>
                            context.pushNamed(RoutesName.archivedCasesScreen),
                      ),
                      const _SectionDivider(),
                      _SectionTitle('SUPPORT'),
                      _DrawerItem(
                        icon: Icons.chat_rounded,
                        title: 'Contact on WhatsApp',
                        subtitle: 'Quick support via chat',
                        iconColor: const Color(0xFF25D366),
                        trailing: DrawerTrailing.external,
                        onTap: () => _contactWhatsApp(context),
                      ),
                      _DrawerItem(
                        icon: Icons.email_rounded,
                        title: 'Email Us',
                        subtitle: _DrawerConfig.supportEmail,
                        iconColor: RC.gold,
                        trailing: DrawerTrailing.external,
                        onTap: () => _contactEmail(context),
                      ),
                      _DrawerItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & FAQ',
                        iconColor: RC.textSecondary,
                        trailing: DrawerTrailing.external,
                        onTap: () =>
                            _launchUrl(context, _DrawerConfig.helpCenterUrl),
                      ),
                      const _SectionDivider(),
                      _SectionTitle('ABOUT APP'),
                      _DrawerItem(
                        icon: Icons.info_outline_rounded,
                        title: 'About Right Case',
                        onTap: () => _showAbout(context),
                      ),
                      _DrawerItem(
                        icon: Icons.share_rounded,
                        title: 'Share App',
                        trailing: DrawerTrailing.external,
                        onTap: _shareApp,
                      ),
                      _DrawerItem(
                        icon: Icons.star_rate_rounded,
                        title: 'Rate Us',
                        trailing: DrawerTrailing.external,
                        onTap: () => _openStoreListing(context),
                      ),
                      _DrawerItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        trailing: DrawerTrailing.external,
                        onTap: () =>
                            _launchUrl(context, _DrawerConfig.privacyPolicyUrl),
                      ),
                      _DrawerItem(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        trailing: DrawerTrailing.external,
                        onTap: () => _launchUrl(
                            context, _DrawerConfig.termsOfServiceUrl),
                      ),
                      const _SectionDivider(),
                      _SectionTitle('ACCOUNT'),
                      _DrawerItem(
                        icon: Icons.lock_reset_rounded,
                        title: 'Change Password',
                        iconColor: RC.textSecondary,
                        onTap: () =>
                            context.pushNamed(RoutesName.changePasswordScreen),
                      ),
                      _DrawerItem(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        iconColor: RC.textSecondary,
                        trailing: DrawerTrailing.none,
                        onTap: () => _confirmLogout(context, logoutVM),
                      ),
                      _DrawerItem(
                        icon: Icons.delete_forever_rounded,
                        title: 'Delete Account',
                        iconColor: RC.danger,
                        textColor: RC.danger,
                        trailing: DrawerTrailing.none,
                        onTap: () => _showDeleteAccountSheet(context),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                const _VersionFooter(),
              ],
            ),

            // Loading overlay — dims content instead of replacing the
            // whole drawer tree, so the header/branding stay visible
            // while logout is in flight.
            if (logoutVM.isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                          color: RC.surface,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [RC.cardShadow]),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                  color: RC.navy, strokeWidth: 2.2)),
                          SizedBox(width: 12.w),
                          Text('Signing out…',
                              style: RC.body().copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Right Case',
      applicationVersion:
          '${_DrawerConfig.appVersion} (${_DrawerConfig.appBuildNumber})',
      applicationIcon: Icon(Icons.gavel_rounded, color: RC.navy, size: 44.sp),
      applicationLegalese: '© ${DateTime.now().year} Right Case Inc.',
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: RC.navy,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Consumer<CurrentUserViewModel>(
        builder: (context, currentUserVM, __) {
          final user = currentUserVM.user;
          final name = user?.name ?? 'Unknown User';
          final email = user?.email ?? 'No email provided';
          final initial =
              name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

          return InkWell(
            onTap: () => _showProfilePreview(context,
                name: name, email: email, initial: initial),
            borderRadius: BorderRadius.circular(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: RC.gold, width: 2.w),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 30.r,
                        backgroundColor: RC.surface,
                        child: Text(initial,
                            style: TextStyle(
                                color: RC.navy,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded,
                        color: RC.textOnDarkMuted, size: 20.sp),
                  ],
                ),
                SizedBox(height: 14.h),
                Text(
                  name,
                  style: TextStyle(
                      color: RC.textOnDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      letterSpacing: 0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  email,
                  style: TextStyle(color: RC.textOnDarkMuted, fontSize: 13.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Profile preview sheet — opened by tapping the header
// ════════════════════════════════════════════════════════════════
class _ProfilePreviewSheet extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  const _ProfilePreviewSheet(
      {required this.name, required this.email, required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Container(
                  width: 36.w,
                  height: 4,
                  decoration: BoxDecoration(
                      color: RC.divider,
                      borderRadius: BorderRadius.circular(2)))),
          SizedBox(height: 18.h),
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(color: RC.navy, shape: BoxShape.circle),
            child: Center(
                child: Text(initial,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w700))),
          ),
          SizedBox(height: 14.h),
          Text(name,
              style: RC
                  .body()
                  .copyWith(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                  child: Text(email,
                      overflow: TextOverflow.ellipsis,
                      style: RC
                          .caption(color: RC.textSecondary)
                          .copyWith(fontSize: 12.5.sp))),
              SizedBox(width: 6.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: email));
                  SnakeBars.flutterToast('Email copied', context,
                      type: SnackType.success);
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Icon(Icons.copy_rounded,
                        size: 14.sp, color: RC.textTertiary)),
              ),
            ],
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                SnakeBars.flutterToast(
                    'Profile editing is coming soon', context,
                    type: SnackType.info);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                side: BorderSide(color: RC.divider),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
              icon: Icon(Icons.edit_outlined, size: 16.sp, color: RC.navy),
              label: Text('Edit Profile',
                  style: TextStyle(
                      color: RC.navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Delete-account sheet — password + type "DELETE" to confirm
// (irreversible action)
// ════════════════════════════════════════════════════════════════
// class _DeleteAccountSheet extends StatefulWidget {
//   const _DeleteAccountSheet();
//
//   @override
//   State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
// }
//
// class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
//   final _confirmController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   late final Listenable _inputFieldListener;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _inputFieldListener =
//         Listenable.merge([_confirmController, _passwordController]);
//   }
//
//   bool get _canConfirm =>
//       _confirmController.text.trim().toUpperCase() == 'DELETE' &&
//       _passwordController.text.isNotEmpty;
//
//   @override
//   void dispose() {
//     _confirmController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _handleConfirm() async {
//     final viewModel = context.read<DeleteAccountViewModel>();
//     if (!_canConfirm || viewModel.isLoading) return;
//
//     final result = await viewModel.deleteAccount(
//       password: _passwordController.text,
//       confirmation: _confirmController.text.trim().toUpperCase(),
//     );
//
//     if (!mounted) return;
//
//     if (result.success) {
//       Navigator.pop(context);
//       SnakeBars.flutterToast(result.message, context);
//       // Account no longer exists -- goNamed replaces the whole stack so
//       // back can't return into a deleted account. Previously this used
//       // Navigator.pushNamedAndRemoveUntil, the same wrong-Navigator-API
//       // issue found in the forgot-password flow -- this app navigates via
//       // go_router everywhere else.
//       context.goNamed(RoutesName.signInScreen);
//     } else {
//       SnakeBars.flutterToast(result.message, context, type: SnackType.error);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final viewModel = context.watch<DeleteAccountViewModel>();
//
//     return Padding(
//       padding:
//           EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: Container(
//         decoration: BoxDecoration(
//             color: RC.surface,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
//         padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Center(
//                 child: Container(
//                   width: 36.w,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: RC.divider,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               Center(
//                 child: Container(
//                   width: 56.w,
//                   height: 56.w,
//                   decoration: BoxDecoration(
//                       color: RC.dangerSurface, shape: BoxShape.circle),
//                   child: Icon(Icons.delete_forever_outlined,
//                       size: 26.sp, color: RC.danger),
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               Text('Delete your account?',
//                   textAlign: TextAlign.center,
//                   style: RC
//                       .body()
//                       .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w700)),
//               SizedBox(height: 6.h),
//               Text(
//                 'This permanently deletes all your cases, clients, hearings, and files. This cannot be undone.',
//                 textAlign: TextAlign.center,
//                 style: RC
//                     .caption(color: RC.textSecondary)
//                     .copyWith(fontSize: 12.5.sp, height: 1.5),
//               ),
//               SizedBox(height: 18.h),
//
//               // Password field -- new. The backend requires this as an
//               // independent factor, since typing a word alone proves
//               // nothing if a session is left open on a shared device.
//               Text('Enter your password to confirm it\'s really you',
//                   style: RC
//                       .caption(color: RC.textSecondary)
//                       .copyWith(fontSize: 12.sp)),
//               SizedBox(height: 8.h),
//               TextField(
//                 controller: _passwordController,
//                 obscureText: viewModel.obscurePassword,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//                 decoration: InputDecoration(
//                   hintText: 'Current password',
//                   hintStyle: TextStyle(
//                       color: RC.textTertiary, fontWeight: FontWeight.w500),
//                   filled: true,
//                   fillColor: RC.background,
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
//                   suffixIcon: IconButton(
//                       icon: Icon(
//                         viewModel.obscurePassword
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                         size: 20.sp,
//                         color: RC.textSecondary,
//                       ),
//                       onPressed: () => viewModel.toggleObscurePassword()),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.divider, width: 0.5)),
//                   enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.divider, width: 0.5)),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.danger, width: 1.5)),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//
//               Text.rich(
//                 TextSpan(
//                   text: 'Type ',
//                   style: RC
//                       .caption(color: RC.textSecondary)
//                       .copyWith(fontSize: 12.sp),
//                   children: [
//                     TextSpan(
//                       text: 'DELETE',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w800,
//                         color: RC.danger,
//                       ),
//                     ),
//                     const TextSpan(text: ' to confirm'),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 8.h),
//               TextField(
//                 controller: _confirmController,
//                 textCapitalization: TextCapitalization.characters,
//                 style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//                 decoration: InputDecoration(
//                   hintText: 'DELETE',
//                   hintStyle: TextStyle(
//                       color: RC.textTertiary, fontWeight: FontWeight.w500),
//                   filled: true,
//                   fillColor: RC.background,
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.divider, width: 0.5)),
//                   enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.divider, width: 0.5)),
//                   focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.r),
//                       borderSide: BorderSide(color: RC.danger, width: 1.5)),
//                 ),
//               ),
//               SizedBox(height: 18.h),
//               AnimatedBuilder(
//                 animation: _inputFieldListener,
//                 builder: (context, child) {
//                   return SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _canConfirm && !viewModel.isLoading
//                           ? _handleConfirm
//                           : null,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: RC.danger,
//                         disabledBackgroundColor:
//                             RC.danger.withValues(alpha: 0.35),
//                         padding: EdgeInsets.symmetric(vertical: 14.h),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.r)),
//                         elevation: 0,
//                       ),
//                       child: viewModel.isLoading
//                           ? SizedBox(
//                               width: 18.w,
//                               height: 18.w,
//                               child: const CircularProgressIndicator(
//                                   color: Colors.white, strokeWidth: 2.2),
//                             )
//                           : Text(
//                               'Permanently Delete Account',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13.5.sp,
//                               ),
//                             ),
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(height: 8.h),
//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed:
//                       viewModel.isLoading ? null : () => Navigator.pop(context),
//                   child: Text('Cancel',
//                       style: TextStyle(
//                           color: RC.textSecondary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13.5.sp)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _confirmController = TextEditingController();
  final _passwordController = TextEditingController();

  late final Listenable _inputFieldListener;

  @override
  void initState() {
    super.initState();

    _inputFieldListener =
        Listenable.merge([_confirmController, _passwordController]);
    // Dismiss a stale error the moment the user starts correcting a field
    // (most commonly: retyping a mistaken password) rather than leaving it
    // visible until they resubmit.
    _inputFieldListener.addListener(_handleFieldsChanged);
  }

  bool get _canConfirm =>
      _confirmController.text.trim().toUpperCase() == 'DELETE' &&
      _passwordController.text.isNotEmpty;

  void _handleFieldsChanged() {
    final vm = context.read<DeleteAccountViewModel>();
    if (vm.hasError) vm.clearError();
  }

  @override
  void dispose() {
    _inputFieldListener.removeListener(_handleFieldsChanged);
    _confirmController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final viewModel = context.read<DeleteAccountViewModel>();
    if (!_canConfirm || viewModel.isLoading) return;

    final result = await viewModel.deleteAccount(
      password: _passwordController.text,
      confirmation: _confirmController.text.trim().toUpperCase(),
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.pop(context);
      SnakeBars.flutterToast(result.message, context);
      // Account no longer exists -- goNamed replaces the whole stack so
      // back can't return into a deleted account.
      context.goNamed(RoutesName.signInScreen);
    }
    // Failure: nothing to do here. viewModel.errorMessage now holds the
    // reason and the inline banner below reacts to it via context.watch.
    // Previously this called SnakeBars.flutterToast(result.message,
    // context) here -- that toast was real and correctly worded, it just
    // rendered on the Home screen's Scaffold underneath this modal route
    // (the nearest Scaffold ancestor from this sheet's own context), so it
    // was visually buried behind the sheet itself.
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DeleteAccountViewModel>();

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
            color: RC.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RC.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                      color: RC.dangerSurface, shape: BoxShape.circle),
                  child: Icon(Icons.delete_forever_outlined,
                      size: 26.sp, color: RC.danger),
                ),
              ),
              SizedBox(height: 12.h),
              Text('Delete your account?',
                  textAlign: TextAlign.center,
                  style: RC
                      .body()
                      .copyWith(fontSize: 17.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              Text(
                'This permanently deletes all your cases, clients, hearings, and files. This cannot be undone.',
                textAlign: TextAlign.center,
                style: RC
                    .caption(color: RC.textSecondary)
                    .copyWith(fontSize: 12.5.sp, height: 1.5),
              ),

              // Inline error banner -- this is the actual fix for the
              // toast-hidden-behind-the-sheet problem. No SnackBar/toast
              // involved, so there's no cross-route context/Overlay lookup
              // that can resolve to the wrong layer. Keyed on errorVersion
              // so the entrance animation replays even for two identical
              // consecutive error messages.
              if (viewModel.hasError) ...[
                SizedBox(height: 14.h),
                _ErrorBanner(
                  key: ValueKey(viewModel.errorVersion),
                  message: viewModel.errorMessage!,
                ),
              ],

              SizedBox(height: 18.h),

              // Password field -- the backend requires this as an
              // independent factor, since typing a word alone proves
              // nothing if a session is left open on a shared device.
              Text('Enter your password to confirm it\'s really you',
                  style: RC
                      .caption(color: RC.textSecondary)
                      .copyWith(fontSize: 12.sp)),
              SizedBox(height: 8.h),
              TextField(
                controller: _passwordController,
                obscureText: viewModel.obscurePassword,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Current password',
                  hintStyle: TextStyle(
                      color: RC.textTertiary, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: RC.background,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                  suffixIcon: IconButton(
                      icon: Icon(
                        viewModel.obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20.sp,
                        color: RC.textSecondary,
                      ),
                      onPressed: () => viewModel.toggleObscurePassword()),
                  // Border reflects the VM's error state directly -- ties
                  // the failure visually to the field that's the most
                  // likely cause (wrong password), on top of the banner.
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: viewModel.hasError ? RC.danger : RC.divider,
                          width: viewModel.hasError ? 1.2 : 0.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                          color: viewModel.hasError ? RC.danger : RC.divider,
                          width: viewModel.hasError ? 1.2 : 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: RC.danger, width: 1.5)),
                ),
              ),
              SizedBox(height: 16.h),

              Text.rich(
                TextSpan(
                  text: 'Type ',
                  style: RC
                      .caption(color: RC.textSecondary)
                      .copyWith(fontSize: 12.sp),
                  children: [
                    TextSpan(
                      text: 'DELETE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: RC.danger,
                      ),
                    ),
                    const TextSpan(text: ' to confirm'),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _confirmController,
                textCapitalization: TextCapitalization.characters,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: TextStyle(
                      color: RC.textTertiary, fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: RC.background,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: RC.divider, width: 0.5)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: RC.divider, width: 0.5)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: RC.danger, width: 1.5)),
                ),
              ),
              SizedBox(height: 18.h),
              AnimatedBuilder(
                animation: _inputFieldListener,
                builder: (context, child) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canConfirm && !viewModel.isLoading
                          ? _handleConfirm
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RC.danger,
                        disabledBackgroundColor:
                            RC.danger.withValues(alpha: 0.35),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      child: viewModel.isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.2),
                            )
                          : Text(
                              'Permanently Delete Account',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5.sp,
                              ),
                            ),
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed:
                      viewModel.isLoading ? null : () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: RC.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact inline failure banner. Deliberately not a toast/SnackBar --
/// see the note in _handleConfirm for why those render behind this sheet.
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: RC.dangerSurface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: RC.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18.sp, color: RC.danger),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: RC.danger,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms)
        .shake(hz: 4, curve: Curves.easeInOutCubic, duration: 400.ms);
  }
}

// ════════════════════════════════════════════════════════════════
// Shared drawer primitives
// ════════════════════════════════════════════════════════════════
enum DrawerTrailing { chevron, external, none }

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final DrawerTrailing trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.textColor,
    this.trailing = DrawerTrailing.chevron,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
            color: (iconColor ?? RC.textSecondary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r)),
        child: Icon(
          icon,
          color: iconColor ?? RC.textSecondary,
          size: 21.sp,
        ),
      ),
      title: Text(title,
          style: TextStyle(
              color: textColor ?? RC.textPrimary,
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: RC.textSecondary, fontSize: 11.5.sp),
            )
          : null,
      trailing: switch (trailing) {
        DrawerTrailing.chevron => Icon(
            Icons.chevron_right_rounded,
            size: 18.sp,
            color: RC.textTertiary.withValues(alpha: 0.6),
          ),
        DrawerTrailing.external => Icon(
            Icons.north_east_rounded,
            size: 14.sp,
            color: RC.textTertiary.withValues(alpha: 0.6),
          ),
        DrawerTrailing.none => null,
      },
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      hoverColor: RC.gold.withValues(alpha: 0.05),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Text(title,
          style: TextStyle(
              color: RC.textTertiary,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1)),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();
  @override
  Widget build(BuildContext context) =>
      Divider(color: RC.divider, height: 24.h, indent: 24.w, endIndent: 24.w);
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Center(
        child: Text(
          'Right Case · v${_DrawerConfig.appVersion}',
          style: TextStyle(
              color: RC.textTertiary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
