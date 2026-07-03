import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/utils/routes/routes_names.dart';
import 'package:right_case/view_model/auth_view_models/login_view_model.dart';
import 'package:right_case/view_model/auth_view_models/logout_view_model.dart';
import 'package:right_case/view_model/auth_view_models/register_view_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Ensure your _RC color class is accessible. I've included it here for completeness.
class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);

  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const dangerText = Color(0xFF991B1B);

  static const divider = Color(0xFFE5E1D8);
}

class DrawerView extends StatelessWidget {
  const DrawerView({super.key});

  // --- Enterprise Integration Helpers ---

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $urlString');
    }
  }

  void _contactWhatsApp() {
    // Replace with your actual business WhatsApp number (include country code, omit '+')
    final String phoneNumber = "1234567890";
    final String message =
        Uri.encodeComponent("Hello Right Case Support, I need some help.");
    _launchUrl("whatsapp://send?phone=$phoneNumber&text=$message");
  }

  void _contactEmail() {
    // Replace with your actual support email
    final String email = "support@rightcase.com";
    final String subject = Uri.encodeComponent("App Support Inquiry");
    _launchUrl("mailto:$email?subject=$subject");
  }

  void _shareApp() {
    // Replace with your actual app store link or landing page
    SharePlus.instance.share(
      ShareParams(
        text:
            'Check out Right Case, the best app for managing your legal workspace! Download here: https://yourwebsite.com/download',
        subject: 'Right Case App',
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _RC.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _RC.danger, size: 28.sp),
            SizedBox(width: 8.w),
            Text("Delete Account",
                style: TextStyle(
                    color: _RC.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          "Are you sure you want to permanently delete your account? This action cannot be undone and all data will be lost.",
          style: TextStyle(color: _RC.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: TextStyle(color: _RC.textPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _RC.danger,
              foregroundColor: _RC.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Call your delete account view model method here
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoutVM = Provider.of<LogoutViewModel>(context);

    return Drawer(
      backgroundColor: _RC.background,
      child: logoutVM.isLoading
          ? Center(
              child: CircularProgressIndicator(color: _RC.navy),
            )
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(height: 8.h),

                      // WORKSPACE SECTION
                      _buildSectionTitle("WORKSPACE"),
                      _DrawerItem(
                        icon: Icons.archive_rounded,
                        title: "Archived Clients",
                        subtitle: "Restore clients from here",
                        iconColor: _RC.navy,
                        onTap: () => Navigator.pushNamed(
                            context, RoutesName.archivedClientsScreen),
                      ),
                      _DrawerItem(
                        icon: Icons.cases_rounded,
                        title: "Archived Cases",
                        subtitle: "Restore cases from here",
                        iconColor: _RC.navy,
                        onTap: () => Navigator.pushNamed(
                            context, RoutesName.archivedCasesScreen),
                      ),

                      Divider(
                          color: _RC.divider,
                          height: 24.h,
                          indent: 24.w,
                          endIndent: 24.w),

                      // SUPPORT SECTION
                      _buildSectionTitle("SUPPORT"),
                      _DrawerItem(
                        icon: Icons.chat_rounded,
                        title: "Contact on WhatsApp",
                        subtitle: "Quick support via chat",
                        iconColor:
                            const Color(0xFF25D366), // Standard WhatsApp Green
                        onTap: _contactWhatsApp,
                      ),
                      _DrawerItem(
                        icon: Icons.email_rounded,
                        title: "Email Us",
                        subtitle: "support@rightcase.com",
                        iconColor: _RC.gold,
                        onTap: _contactEmail,
                      ),

                      Divider(
                          color: _RC.divider,
                          height: 24.h,
                          indent: 24.w,
                          endIndent: 24.w),

                      // APP INFO SECTION
                      _buildSectionTitle("ABOUT APP"),
                      _DrawerItem(
                        icon: Icons.info_outline_rounded,
                        title: "About Right Case",
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Right Case',
                            applicationVersion:
                                '1.0.0', // Optionally fetch from package_info_plus
                            applicationIcon: Icon(Icons.gavel_rounded,
                                color: _RC.navy, size: 48.sp),
                            applicationLegalese: '© 2026 Right Case Inc.',
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.share_rounded,
                        title: "Share App",
                        onTap: _shareApp,
                      ),
                      _DrawerItem(
                        icon: Icons.star_rate_rounded,
                        title: "Rate Us",
                        onTap: () => _launchUrl(
                            "https://play.google.com/store/apps/details?id=com.yourcompany.rightcase"), // Replace with actual Play Store/App Store link
                      ),
                      _DrawerItem(
                        icon: Icons.privacy_tip_outlined,
                        title: "Privacy Policy",
                        onTap: () => _launchUrl(
                            "https://yourwebsite.com/privacy"), // Replace with actual URL
                      ),

                      Divider(
                          color: _RC.divider,
                          height: 24.h,
                          indent: 24.w,
                          endIndent: 24.w),

                      // ACCOUNT SECTION
                      _buildSectionTitle("ACCOUNT"),
                      _DrawerItem(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        iconColor: _RC.textSecondary,
                        onTap: () async => await logoutVM.logoutUser(context),
                      ),
                      _DrawerItem(
                        icon: Icons.delete_forever_rounded,
                        title: "Delete Account",
                        iconColor: _RC.danger,
                        textColor: _RC.dangerText,
                        onTap: () => _showDeleteConfirmation(context),
                      ),

                      SizedBox(height: 32.h), // Bottom padding
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.only(top: 60.h, bottom: 24.h, left: 24.w, right: 24.w),
      decoration: const BoxDecoration(
        color: _RC.navy,
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
      ),
      child: Consumer2<RegisterViewModel, LoginViewModel>(
        builder: (context, registerVM, loginVM, child) {
          final user = registerVM.dbUser;
          final userInfo = loginVM.dbUser;
          final name = user?.name ?? userInfo?.name ?? "Unknown User";
          final email = user?.email ?? userInfo?.email ?? "No email provided";
          final initial =
              name.isNotEmpty ? name.characters.first.toUpperCase() : 'X';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _RC.gold, width: 2.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: CircleAvatar(
                  radius: 32.r,
                  backgroundColor: _RC.surface,
                  child: Text(
                    initial,
                    style: TextStyle(
                        color: _RC.navy,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                name,
                style: TextStyle(
                  color: _RC.textOnDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                email,
                style: TextStyle(
                  color: _RC.textOnDarkMuted,
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: _RC.textTertiary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (iconColor ?? _RC.textSecondary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? _RC.textSecondary,
          size: 22.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? _RC.textPrimary,
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: _RC.textSecondary,
                fontSize: 12.sp,
              ),
            )
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      hoverColor: _RC.gold.withValues(alpha: 0.05),
    );
  }
}
